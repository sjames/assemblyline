/// Constraint Parser Module
/// Parses constraint strings into an AST for evaluation

use serde::{Deserialize, Serialize};

/// Comparison operators
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum CompOp {
    Lt,  // <
    Gt,  // >
    Le,  // <=
    Ge,  // >=
    Eq,  // ==
    Ne,  // !=
}

/// Arithmetic operators
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum ArithOp {
    Add,      // +
    Sub,      // -
    Mul,      // *
    Div,      // /
}

/// Expression AST
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
pub enum Expr {
    /// Integer literal
    IntLiteral(i64),
    /// Boolean literal
    BoolLiteral(bool),
    /// String literal
    StringLiteral(String),
    /// Parameter reference: feature_id.param_name
    ParamRef { feature_id: String, param_name: String },
    /// Feature selection: feature_id is selected
    FeatureSelected(String),
    /// Comparison: left op right
    Comparison { op: CompOp, left: Box<Expr>, right: Box<Expr> },
    /// Implication: left => right
    Implication { left: Box<Expr>, right: Box<Expr> },
    /// Logical AND: left && right
    And { left: Box<Expr>, right: Box<Expr> },
    /// Logical OR: left || right
    Or { left: Box<Expr>, right: Box<Expr> },
    /// Logical NOT: !expr
    Not(Box<Expr>),
    /// Arithmetic: left op right
    Arithmetic { op: ArithOp, left: Box<Expr>, right: Box<Expr> },
}

/// Parse a constraint string into an expression AST
///
/// Supported syntax:
/// - Comparisons: cache_size >= 16, max_users < 1000
/// - Implications: enable_compression => cache_size >= 128
/// - Feature predicates: F-CACHE is selected
/// - Arithmetic: cache_size + 100, max_users * 2
/// - Logical: expr && expr, expr || expr, !expr
pub fn parse_constraint(input: &str) -> Result<Expr, String> {
    let input = input.trim();

    // Try to parse as implication first (lowest precedence)
    if let Some(pos) = find_operator(input, "=>") {
        let left = parse_constraint(&input[..pos])?;
        let right = parse_constraint(&input[pos + 2..])?;
        return Ok(Expr::Implication {
            left: Box::new(left),
            right: Box::new(right),
        });
    }

    // Try to parse as OR
    if let Some(pos) = find_operator(input, "||") {
        let left = parse_constraint(&input[..pos])?;
        let right = parse_constraint(&input[pos + 2..])?;
        return Ok(Expr::Or {
            left: Box::new(left),
            right: Box::new(right),
        });
    }

    // Try to parse as AND
    if let Some(pos) = find_operator(input, "&&") {
        let left = parse_constraint(&input[..pos])?;
        let right = parse_constraint(&input[pos + 2..])?;
        return Ok(Expr::And {
            left: Box::new(left),
            right: Box::new(right),
        });
    }

    // Try to parse as comparison
    for (op_str, op) in &[
        (">=", CompOp::Ge),
        ("<=", CompOp::Le),
        ("==", CompOp::Eq),
        ("!=", CompOp::Ne),
        (">", CompOp::Gt),
        ("<", CompOp::Lt),
    ] {
        if let Some(pos) = find_operator(input, op_str) {
            let left = parse_expr(&input[..pos])?;
            let right = parse_expr(&input[pos + op_str.len()..])?;
            return Ok(Expr::Comparison {
                op: op.clone(),
                left: Box::new(left),
                right: Box::new(right),
            });
        }
    }

    // Try to parse as NOT
    if input.starts_with('!') {
        let inner = parse_constraint(&input[1..])?;
        return Ok(Expr::Not(Box::new(inner)));
    }

    // Parse as expression (literal, param ref, feature selection, arithmetic)
    parse_expr(input)
}

/// Parse an expression (not a full constraint)
fn parse_expr(input: &str) -> Result<Expr, String> {
    let input = input.trim();

    // Check for "is selected" feature predicate FIRST (before arithmetic)
    if input.contains(" is selected") {
        let feature_id = input.replace(" is selected", "").trim().to_string();
        return Ok(Expr::FeatureSelected(feature_id));
    }

    // Try arithmetic operators BEFORE parameter references
    // This ensures "F-TEST.size + 50" is parsed as (F-TEST.size) + (50), not as F-TEST.(size + 50)
    for (op_str, op) in &[
        ("+", ArithOp::Add),
        ("-", ArithOp::Sub),
        ("*", ArithOp::Mul),
        ("/", ArithOp::Div),
    ] {
        if let Some(pos) = find_operator(input, op_str) {
            let left = parse_expr(&input[..pos])?;
            let right = parse_expr(&input[pos + op_str.len()..])?;
            return Ok(Expr::Arithmetic {
                op: op.clone(),
                left: Box::new(left),
                right: Box::new(right),
            });
        }
    }

    // Check for parameter reference (contains dot) AFTER arithmetic
    // At this point we know there are no operators, so the whole thing is a param ref
    if input.contains('.') {
        let parts: Vec<&str> = input.split('.').collect();
        if parts.len() == 2 {
            return Ok(Expr::ParamRef {
                feature_id: parts[0].trim().to_string(),
                param_name: parts[1].trim().to_string(),
            });
        }
    }

    // Try to parse as boolean literal
    match input {
        "true" => return Ok(Expr::BoolLiteral(true)),
        "false" => return Ok(Expr::BoolLiteral(false)),
        _ => {}
    }

    // Try to parse as integer
    if let Ok(n) = input.parse::<i64>() {
        return Ok(Expr::IntLiteral(n));
    }

    // Try to parse as string literal (remove quotes if present)
    if (input.starts_with('"') && input.ends_with('"'))
        || (input.starts_with('\'') && input.ends_with('\''))
    {
        return Ok(Expr::StringLiteral(input[1..input.len() - 1].to_string()));
    }

    // Otherwise treat as string (for enum values without quotes)
    Ok(Expr::StringLiteral(input.to_string()))
}

/// Find operator position, skipping parentheses
/// For single-char operators like + - * /, requires whitespace on at least one side
/// to avoid matching hyphens in identifiers like "F-CACHE"
fn find_operator(input: &str, op: &str) -> Option<usize> {
    let mut paren_depth = 0;
    let chars: Vec<char> = input.chars().collect();
    let op_chars: Vec<char> = op.chars().collect();

    for i in 0..chars.len() {
        if chars[i] == '(' {
            paren_depth += 1;
        } else if chars[i] == ')' {
            paren_depth -= 1;
        } else if paren_depth == 0 {
            // Check if operator starts at position i
            if i + op_chars.len() <= chars.len() {
                let matches = (0..op_chars.len()).all(|j| chars[i + j] == op_chars[j]);
                if matches {
                    // For single-character operators, check for whitespace boundaries
                    // to avoid matching hyphens in identifiers
                    if op.len() == 1 && (op == "+" || op == "-" || op == "*" || op == "/") {
                        let has_space_before = i == 0 || chars[i - 1].is_whitespace();
                        let has_space_after = i + op.len() >= chars.len() || chars[i + op.len()].is_whitespace();

                        // Require whitespace on at least one side
                        if has_space_before || has_space_after {
                            return Some(i);
                        }
                    } else {
                        // For multi-character operators (>=, <=, ==, etc.), no whitespace check needed
                        return Some(i);
                    }
                }
            }
        }
    }

    None
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_parse_simple_comparison() {
        let expr = parse_constraint("cache_size >= 16").unwrap();
        match expr {
            Expr::Comparison { op: CompOp::Ge, .. } => {}
            _ => panic!("Expected comparison"),
        }
    }

    #[test]
    fn test_parse_implication() {
        let expr = parse_constraint("enable_compression => cache_size >= 128").unwrap();
        match expr {
            Expr::Implication { .. } => {}
            _ => panic!("Expected implication"),
        }
    }

    #[test]
    fn test_parse_feature_selected() {
        let expr = parse_constraint("F-CACHE is selected").unwrap();
        match expr {
            Expr::FeatureSelected(id) => assert_eq!(id, "F-CACHE"),
            _ => panic!("Expected feature selected"),
        }
    }

    #[test]
    fn test_parse_param_ref() {
        let expr = parse_expr("F-CACHE.cache_size").unwrap();
        match expr {
            Expr::ParamRef { feature_id, param_name } => {
                assert_eq!(feature_id, "F-CACHE");
                assert_eq!(param_name, "cache_size");
            }
            _ => panic!("Expected param ref"),
        }
    }

    #[test]
    fn test_parse_arithmetic() {
        let expr = parse_expr("cache_size + 100").unwrap();
        match expr {
            Expr::Arithmetic { op: ArithOp::Add, .. } => {}
            _ => panic!("Expected arithmetic"),
        }
    }

    #[test]
    fn test_parse_and() {
        let expr = parse_constraint("cache_size >= 16 && cache_size <= 2048").unwrap();
        match expr {
            Expr::And { .. } => {}
            _ => panic!("Expected AND"),
        }
    }

    #[test]
    fn test_parse_or() {
        let expr = parse_constraint("cache_size == 1024 || cache_size == 2048").unwrap();
        match expr {
            Expr::Or { .. } => {}
            _ => panic!("Expected OR"),
        }
    }
}
