#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════╗
║  DEMO 5: EVOLUTIONARY META-PROGRAMMING                         ║
║  ────────────────────────────────────────────────────────────    ║
║  Genetic programming that evolves symbolic mathematical         ║
║  expressions. Not just fitting data — DISCOVERING FORMULAS.     ║
║                                                                  ║
║  The system evolves expression trees using crossover, mutation, ║
║  and selection. It can rediscover physical laws from data.       ║
╚══════════════════════════════════════════════════════════════════╝
"""

import numpy as np
import random
import copy
from typing import Optional, Tuple, List

# ── Expression Tree ────────────────────────────────────────────
OPERATORS = {
    '+': (2, lambda a, b: a + b),
    '-': (2, lambda a, b: a - b),
    '*': (2, lambda a, b: a * b),
    '/': (2, lambda a, b: np.where(np.abs(b) > 1e-10, a / b, 0)),
    'sin': (1, lambda a: np.sin(a)),
    'cos': (1, lambda a: np.cos(a)),
    'exp': (1, lambda a: np.clip(np.exp(np.clip(a, -10, 10)), -1e10, 1e10)),
    'sqrt': (1, lambda a: np.sqrt(np.abs(a))),
    'sq': (1, lambda a: a ** 2),
    'cube': (1, lambda a: a ** 3),
}

BINARY_OPS = [op for op, (arity, _) in OPERATORS.items() if arity == 2]
UNARY_OPS = [op for op, (arity, _) in OPERATORS.items() if arity == 1]
CONSTANTS = [0.5, 1.0, 2.0, 3.0, np.pi, np.e]


class ExprNode:
    """A node in an expression tree."""
    def __init__(self, op=None, value=None, var_idx=None,
                 left=None, right=None):
        self.op = op          # Operator string
        self.value = value    # Constant value
        self.var_idx = var_idx  # Variable index (x0, x1, ...)
        self.left = left      # Left child
        self.right = right    # Right child

    def evaluate(self, X: np.ndarray) -> np.ndarray:
        """Evaluate expression on data matrix X (n_samples x n_vars)."""
        if self.value is not None:
            return np.full(X.shape[0], self.value)
        if self.var_idx is not None:
            return X[:, self.var_idx]
        if self.op is not None:
            arity, func = OPERATORS[self.op]
            if arity == 1:
                a = self.left.evaluate(X)
                return func(a)
            else:
                a = self.left.evaluate(X)
                b = self.right.evaluate(X)
                return func(a, b)
        return np.zeros(X.shape[0])

    def to_string(self) -> str:
        """Pretty-print the expression."""
        if self.value is not None:
            if self.value == np.pi:
                return "π"
            if self.value == np.e:
                return "e"
            if self.value == int(self.value):
                return str(int(self.value))
            return f"{self.value:.2f}"
        if self.var_idx is not None:
            return f"x{self.var_idx}"
        if self.op is not None:
            arity = OPERATORS[self.op][0]
            if arity == 1:
                return f"{self.op}({self.left.to_string()})"
            else:
                return f"({self.left.to_string()} {self.op} {self.right.to_string()})"
        return "?"

    def depth(self) -> int:
        d = 0
        if self.left:
            d = max(d, self.left.depth() + 1)
        if self.right:
            d = max(d, self.right.depth() + 1)
        return d

    def size(self) -> int:
        s = 1
        if self.left:
            s += self.left.size()
        if self.right:
            s += self.right.size()
        return s

    def copy(self):
        return copy.deepcopy(self)

    def all_nodes(self) -> list:
        """Collect all nodes in the tree."""
        nodes = [self]
        if self.left:
            nodes.extend(self.left.all_nodes())
        if self.right:
            nodes.extend(self.right.all_nodes())
        return nodes


# ── Random Tree Generation ────────────────────────────────────
def random_tree(n_vars: int, max_depth: int = 4, depth: int = 0) -> ExprNode:
    """Generate a random expression tree."""
    if depth >= max_depth or (depth > 1 and random.random() < 0.3):
        # Terminal: variable or constant
        if random.random() < 0.6:
            return ExprNode(var_idx=random.randint(0, n_vars - 1))
        else:
            return ExprNode(value=random.choice(CONSTANTS))

    # Operator node
    if random.random() < 0.6:
        op = random.choice(BINARY_OPS)
        return ExprNode(op=op,
                        left=random_tree(n_vars, max_depth, depth + 1),
                        right=random_tree(n_vars, max_depth, depth + 1))
    else:
        op = random.choice(UNARY_OPS)
        return ExprNode(op=op,
                        left=random_tree(n_vars, max_depth, depth + 1))


# ── Genetic Operations ────────────────────────────────────────
def crossover(parent1: ExprNode, parent2: ExprNode) -> ExprNode:
    """Subtree crossover: swap random subtrees between parents."""
    child = parent1.copy()
    donor = parent2.copy()

    child_nodes = child.all_nodes()
    donor_nodes = donor.all_nodes()

    # Pick random crossover points
    c_point = random.choice(child_nodes)
    d_point = random.choice(donor_nodes)

    # Replace child subtree with donor subtree
    c_point.op = d_point.op
    c_point.value = d_point.value
    c_point.var_idx = d_point.var_idx
    c_point.left = d_point.left
    c_point.right = d_point.right

    return child

def mutate(tree: ExprNode, n_vars: int, p: float = 0.15) -> ExprNode:
    """Point mutation: randomly modify nodes."""
    tree = tree.copy()
    for node in tree.all_nodes():
        if random.random() < p:
            if node.value is not None:
                # Mutate constant
                if random.random() < 0.5:
                    node.value = random.choice(CONSTANTS)
                else:
                    node.value *= (1 + random.gauss(0, 0.3))
            elif node.var_idx is not None:
                node.var_idx = random.randint(0, n_vars - 1)
            elif node.op is not None:
                arity = OPERATORS[node.op][0]
                if arity == 1:
                    node.op = random.choice(UNARY_OPS)
                else:
                    node.op = random.choice(BINARY_OPS)
    return tree

def subtree_mutation(tree: ExprNode, n_vars: int) -> ExprNode:
    """Replace a random subtree with a new random tree."""
    tree = tree.copy()
    nodes = tree.all_nodes()
    target = random.choice(nodes)
    new_subtree = random_tree(n_vars, max_depth=3)
    target.op = new_subtree.op
    target.value = new_subtree.value
    target.var_idx = new_subtree.var_idx
    target.left = new_subtree.left
    target.right = new_subtree.right
    return tree


# ── Fitness Function ──────────────────────────────────────────
def fitness(tree: ExprNode, X: np.ndarray, y: np.ndarray,
            parsimony_coeff: float = 0.001) -> float:
    """
    Fitness = negative (MSE + parsimony penalty).
    Higher is better. Penalizes complexity to encourage simple expressions.
    """
    try:
        pred = tree.evaluate(X)
        if np.any(np.isnan(pred)) or np.any(np.isinf(pred)):
            return -1e10
        mse = np.mean((pred - y) ** 2)
        complexity_penalty = parsimony_coeff * tree.size()
        return -(mse + complexity_penalty)
    except:
        return -1e10


# ── Evolution Engine ──────────────────────────────────────────
def evolve(X: np.ndarray, y: np.ndarray, n_vars: int,
           pop_size: int = 500, n_generations: int = 100,
           tournament_size: int = 7, elite_size: int = 5,
           verbose: bool = True) -> Tuple[ExprNode, List[float]]:
    """Run genetic programming evolution."""

    # Initialize population
    population = [random_tree(n_vars, max_depth=4) for _ in range(pop_size)]
    best_fitness_history = []
    best_overall = None
    best_overall_fitness = -1e10

    for gen in range(n_generations):
        # Evaluate fitness
        fitnesses = [fitness(t, X, y) for t in population]

        # Track best
        gen_best_idx = np.argmax(fitnesses)
        gen_best_fitness = fitnesses[gen_best_idx]
        best_fitness_history.append(gen_best_fitness)

        if gen_best_fitness > best_overall_fitness:
            best_overall_fitness = gen_best_fitness
            best_overall = population[gen_best_idx].copy()

        if verbose and gen % 20 == 0:
            expr_str = population[gen_best_idx].to_string()
            if len(expr_str) > 50:
                expr_str = expr_str[:47] + "..."
            print(f"    Gen {gen:4d} | Best fitness: {gen_best_fitness:>12.4f} | "
                  f"Size: {population[gen_best_idx].size():>3d} | {expr_str}")

        # Selection and reproduction
        new_population = []

        # Elitism
        elite_indices = np.argsort(fitnesses)[-elite_size:]
        for idx in elite_indices:
            new_population.append(population[idx].copy())

        while len(new_population) < pop_size:
            # Tournament selection
            candidates = random.sample(range(pop_size), tournament_size)
            parent1_idx = max(candidates, key=lambda i: fitnesses[i])

            candidates = random.sample(range(pop_size), tournament_size)
            parent2_idx = max(candidates, key=lambda i: fitnesses[i])

            parent1 = population[parent1_idx]
            parent2 = population[parent2_idx]

            # Genetic operators
            r = random.random()
            if r < 0.7:
                child = crossover(parent1, parent2)
            elif r < 0.85:
                child = mutate(parent1, n_vars)
            else:
                child = subtree_mutation(parent1, n_vars)

            # Depth limit
            if child.depth() <= 8:
                new_population.append(child)
            else:
                new_population.append(random_tree(n_vars, max_depth=4))

        population = new_population

    return best_overall, best_fitness_history


# ── Test Problems ──────────────────────────────────────────────
def main():
    print("=" * 65)
    print("  EVOLUTIONARY META-PROGRAMMING")
    print("  Symbolic Regression via Genetic Programming")
    print("=" * 65)

    # ── Problem 1: Rediscover y = x² + 2x + 1 ─────────────────
    print("\n  PROBLEM 1: Discover y = x² + 2x + 1")
    print("  " + "─" * 55)
    np.random.seed(42)
    random.seed(42)

    X1 = np.random.uniform(-5, 5, (200, 1))
    y1 = X1[:, 0]**2 + 2*X1[:, 0] + 1

    best1, hist1 = evolve(X1, y1, n_vars=1, pop_size=300,
                           n_generations=80, verbose=True)

    print(f"\n    Discovered formula: {best1.to_string()}")
    pred1 = best1.evaluate(X1)
    mse1 = np.mean((pred1 - y1)**2)
    print(f"    MSE: {mse1:.6f}")

    # ── Problem 2: Rediscover y = sin(x) ──────────────────────
    print(f"\n\n  PROBLEM 2: Discover y = sin(x)")
    print("  " + "─" * 55)
    random.seed(123)

    X2 = np.random.uniform(-np.pi, np.pi, (200, 1))
    y2 = np.sin(X2[:, 0])

    best2, hist2 = evolve(X2, y2, n_vars=1, pop_size=400,
                           n_generations=100, verbose=True)

    print(f"\n    Discovered formula: {best2.to_string()}")
    pred2 = best2.evaluate(X2)
    mse2 = np.mean((pred2 - y2)**2)
    print(f"    MSE: {mse2:.6f}")

    # ── Problem 3: Two-variable: y = x0 * sin(x1) ─────────────
    print(f"\n\n  PROBLEM 3: Discover y = x0 * sin(x1)")
    print("  " + "─" * 55)
    random.seed(456)

    X3 = np.random.uniform(-3, 3, (300, 2))
    y3 = X3[:, 0] * np.sin(X3[:, 1])

    best3, hist3 = evolve(X3, y3, n_vars=2, pop_size=500,
                           n_generations=100, verbose=True)

    print(f"\n    Discovered formula: {best3.to_string()}")
    pred3 = best3.evaluate(X3)
    mse3 = np.mean((pred3 - y3)**2)
    print(f"    MSE: {mse3:.6f}")

    # ── Problem 4: Physics — Kepler's Third Law ────────────────
    print(f"\n\n  PROBLEM 4: Discover Kepler's Third Law (T² ∝ a³)")
    print("  " + "─" * 55)
    random.seed(789)

    # Semi-major axis in AU
    a = np.array([0.387, 0.723, 1.0, 1.524, 5.203, 9.537, 19.19, 30.07])
    # Period in years
    T = np.array([0.241, 0.615, 1.0, 1.881, 11.86, 29.46, 84.01, 164.8])

    X4 = a.reshape(-1, 1)
    y4 = T

    # Use more generations for this hard problem
    best4, hist4 = evolve(X4, y4, n_vars=1, pop_size=500,
                           n_generations=150, verbose=True)

    print(f"\n    Discovered formula: {best4.to_string()}")
    pred4 = best4.evaluate(X4)
    mse4 = np.mean((pred4 - y4)**2)
    print(f"    MSE: {mse4:.6f}")
    print(f"    (True relationship: T = a^(3/2))")

    # Verify predictions
    print(f"\n    Verification:")
    print(f"    {'Planet':>10} {'True T':>10} {'Predicted':>10} {'Error%':>10}")
    planets = ["Mercury", "Venus", "Earth", "Mars", "Jupiter",
               "Saturn", "Uranus", "Neptune"]
    for i, planet in enumerate(planets):
        err = abs(pred4[i] - y4[i]) / y4[i] * 100
        print(f"    {planet:>10} {y4[i]:>10.3f} {pred4[i]:>10.3f} {err:>9.2f}%")

    # ── Summary ────────────────────────────────────────────────
    print(f"\n\n  {'═' * 55}")
    print(f"  SUMMARY OF DISCOVERED FORMULAS")
    print(f"  {'═' * 55}")
    print(f"    Problem 1 (x²+2x+1):     {best1.to_string()}")
    print(f"    Problem 2 (sin(x)):       {best2.to_string()}")
    print(f"    Problem 3 (x0*sin(x1)):   {best3.to_string()}")
    print(f"    Problem 4 (Kepler's law): {best4.to_string()}")
    print(f"\n    ★ Formulas discovered from raw data — no prior knowledge!")
    print("=" * 65)


if __name__ == "__main__":
    main()
