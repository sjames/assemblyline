/// Pure Rust SAT Solver using DPLL algorithm
/// No external dependencies - designed for WASM compatibility
///
/// This module provides a simple but efficient SAT solver for checking
/// satisfiability of propositional formulas in CNF (Conjunctive Normal Form).

use std::collections::HashMap;

/// A literal is represented as an i32:
/// - Positive integers (1, 2, 3, ...) represent variables
/// - Negative integers (-1, -2, -3, ...) represent negated variables
pub type Literal = i32;

/// A clause is a disjunction (OR) of literals
pub type Clause = Vec<Literal>;

/// CNF formula is a conjunction (AND) of clauses
pub type CNF = Vec<Clause>;

/// Assignment of variables to boolean values
/// Index 0 is unused, indices 1..=num_vars are used
type Assignment = Vec<Option<bool>>;

/// SAT solver using DPLL (Davis-Putnam-Logemann-Loveland) algorithm
pub struct SatSolver {
    clauses: CNF,
    num_vars: usize,
    assignment: Assignment,
    decision_level: usize,
}

impl SatSolver {
    /// Create a new SAT solver instance
    ///
    /// # Arguments
    /// * `clauses` - The CNF formula to solve
    /// * `num_vars` - Total number of variables (1..=num_vars)
    pub fn new(clauses: CNF, num_vars: usize) -> Self {
        SatSolver {
            clauses,
            num_vars,
            assignment: vec![None; num_vars + 1], // Index 0 unused
            decision_level: 0,
        }
    }

    /// Check if the formula is satisfiable
    /// Returns true if SAT, false if UNSAT
    pub fn solve(&mut self) -> bool {
        self.dpll()
    }

    /// Get a satisfying assignment if one exists
    /// Only valid if solve() returned true
    pub fn get_model(&self) -> HashMap<i32, bool> {
        let mut model = HashMap::new();
        for var in 1..=self.num_vars {
            if let Some(val) = self.assignment[var] {
                model.insert(var as i32, val);
            }
        }
        model
    }

    /// DPLL recursive backtracking algorithm
    fn dpll(&mut self) -> bool {
        // Unit propagation
        if !self.unit_propagate() {
            return false; // Conflict detected
        }

        // Pure literal elimination (optional optimization)
        self.pure_literal_elimination();

        // Check if all clauses are satisfied
        if self.all_clauses_satisfied() {
            return true;
        }

        // Select an unassigned variable
        if let Some(var) = self.select_variable() {
            // Save current state for backtracking
            let saved_assignment = self.assignment.clone();

            // Try assigning true
            self.assignment[var] = Some(true);
            self.decision_level += 1;
            if self.dpll() {
                return true;
            }

            // Backtrack and try false
            self.assignment = saved_assignment.clone();
            self.assignment[var] = Some(false);
            self.decision_level += 1;
            if self.dpll() {
                return true;
            }

            // Backtrack completely
            self.assignment = saved_assignment;
            self.decision_level -= 1;
            false
        } else {
            // All variables assigned - check satisfaction
            self.all_clauses_satisfied()
        }
    }

    /// Unit propagation: repeatedly assign unit clauses until fixpoint
    /// Returns false if a conflict is detected
    fn unit_propagate(&mut self) -> bool {
        loop {
            let unit_literal = self.find_unit_clause();

            if let Some(lit) = unit_literal {
                let var = lit.abs() as usize;
                let val = lit > 0;

                // Check for conflict
                if let Some(existing_val) = self.assignment[var] {
                    if existing_val != val {
                        return false; // Conflict!
                    }
                } else {
                    self.assignment[var] = Some(val);
                }
            } else {
                // No more unit clauses
                break;
            }
        }
        true
    }

    /// Find a unit clause (clause with exactly one unassigned literal, all others false)
    fn find_unit_clause(&self) -> Option<Literal> {
        for clause in &self.clauses {
            let mut unassigned_lit = None;
            let mut unassigned_count = 0;
            let mut satisfied = false;

            for &lit in clause {
                match self.evaluate_literal(lit) {
                    Some(true) => {
                        satisfied = true;
                        break;
                    }
                    Some(false) => {
                        // Literal is false, continue
                    }
                    None => {
                        unassigned_lit = Some(lit);
                        unassigned_count += 1;
                    }
                }
            }

            if !satisfied {
                if unassigned_count == 0 {
                    // All literals false - conflict (but we return None here,
                    // conflict will be detected in unit_propagate)
                    return None;
                } else if unassigned_count == 1 {
                    return unassigned_lit;
                }
            }
        }
        None
    }

    /// Pure literal elimination: assign variables that appear with only one polarity
    fn pure_literal_elimination(&mut self) {
        let mut literal_polarity: HashMap<i32, bool> = HashMap::new(); // var -> appears_positive
        let mut pure_literals = Vec::new();

        // Find pure literals
        for clause in &self.clauses {
            if self.is_clause_satisfied(clause) {
                continue;
            }

            for &lit in clause {
                let var = lit.abs();
                if self.assignment[var as usize].is_some() {
                    continue;
                }

                let positive = lit > 0;
                match literal_polarity.get(&var) {
                    None => {
                        literal_polarity.insert(var, positive);
                    }
                    Some(&prev_polarity) => {
                        if prev_polarity != positive {
                            // Appears with both polarities - not pure
                            literal_polarity.remove(&var);
                        }
                    }
                }
            }
        }

        // Assign pure literals
        for (var, positive) in literal_polarity {
            if self.assignment[var as usize].is_none() {
                pure_literals.push((var as usize, positive));
            }
        }

        for (var, val) in pure_literals {
            self.assignment[var] = Some(val);
        }
    }

    /// Check if a clause is satisfied under current assignment
    fn is_clause_satisfied(&self, clause: &[Literal]) -> bool {
        for &lit in clause {
            if let Some(true) = self.evaluate_literal(lit) {
                return true;
            }
        }
        false
    }

    /// Check if all clauses are satisfied
    fn all_clauses_satisfied(&self) -> bool {
        for clause in &self.clauses {
            if !self.is_clause_satisfied(clause) {
                return false;
            }
        }
        true
    }

    /// Evaluate a literal under current assignment
    fn evaluate_literal(&self, lit: Literal) -> Option<bool> {
        let var = lit.abs() as usize;
        match self.assignment[var] {
            Some(val) => Some(if lit > 0 { val } else { !val }),
            None => None,
        }
    }

    /// Select an unassigned variable (simple heuristic: first unassigned)
    /// More sophisticated heuristics (VSIDS, etc.) could be added here
    fn select_variable(&self) -> Option<usize> {
        // Simple heuristic: select first unassigned variable
        for var in 1..=self.num_vars {
            if self.assignment[var].is_none() {
                return Some(var);
            }
        }
        None
    }
}

/// Helper function to check SAT without creating a solver instance
pub fn is_sat(clauses: &CNF, num_vars: usize) -> bool {
    if clauses.is_empty() {
        return true; // Empty formula is satisfiable
    }

    let mut solver = SatSolver::new(clauses.clone(), num_vars);
    solver.solve()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_empty_formula() {
        let cnf: CNF = vec![];
        assert!(is_sat(&cnf, 0));
    }

    #[test]
    fn test_single_variable() {
        // (x1)
        let cnf = vec![vec![1]];
        assert!(is_sat(&cnf, 1));
    }

    #[test]
    fn test_contradiction() {
        // (x1) AND (NOT x1)
        let cnf = vec![vec![1], vec![-1]];
        assert!(!is_sat(&cnf, 1));
    }

    #[test]
    fn test_simple_sat() {
        // (x1 OR x2) AND (NOT x1 OR x3) AND (NOT x2 OR NOT x3)
        let cnf = vec![vec![1, 2], vec![-1, 3], vec![-2, -3]];
        assert!(is_sat(&cnf, 3));
    }

    #[test]
    fn test_simple_unsat() {
        // (x1 OR x2) AND (x1 OR NOT x2) AND (NOT x1 OR x2) AND (NOT x1 OR NOT x2)
        let cnf = vec![vec![1, 2], vec![1, -2], vec![-1, 2], vec![-1, -2]];
        assert!(!is_sat(&cnf, 2));
    }

    #[test]
    fn test_unit_propagation() {
        // (x1) AND (NOT x1 OR x2) should propagate to x1=true, x2=true
        let cnf = vec![vec![1], vec![-1, 2]];
        let mut solver = SatSolver::new(cnf, 2);
        assert!(solver.solve());
        let model = solver.get_model();
        assert_eq!(model.get(&1), Some(&true));
        assert_eq!(model.get(&2), Some(&true));
    }

    #[test]
    fn test_larger_formula() {
        // More complex formula with 5 variables
        let cnf = vec![
            vec![1, 2, 3],
            vec![-1, 4],
            vec![-2, 4],
            vec![-3, 5],
            vec![-4, -5],
        ];
        assert!(is_sat(&cnf, 5));
    }
}
