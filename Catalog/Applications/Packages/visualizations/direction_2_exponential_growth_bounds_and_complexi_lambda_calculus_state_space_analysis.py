"""
Algorithms for Lambda Calculus State-Space Analysis

Implements the key algorithms from the research paper:
1. Lambda term representation and substitution
2. Beta-reduction successor enumeration
3. Bounded state-space exploration (BFS)
4. Branching complexity computation
5. State growth analysis
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Union, List, Set, FrozenSet, Dict, Tuple
import random


# --- Lambda Term Representation ---

@dataclass(frozen=True)
class Var:
    """Variable with natural number name."""
    name: int

    def __repr__(self) -> str:
        return str(self.name)


@dataclass(frozen=True)
class App:
    """Application of function to argument."""
    func: 'Term'
    arg: 'Term'

    def __repr__(self) -> str:
        return f"({self.func} {self.arg})"


@dataclass(frozen=True)
class Lam:
    """Lambda abstraction binding a variable."""
    var: int
    body: 'Term'

    def __repr__(self) -> str:
        return f"(λ{self.var}. {self.body})"


Term = Union[Var, App, Lam]


# --- Core Operations ---

def size(t: Term) -> int:
    """Compute the size of a term (number of constructors)."""
    if isinstance(t, Var):
        return 1
    elif isinstance(t, App):
        return 1 + size(t.func) + size(t.arg)
    elif isinstance(t, Lam):
        return 1 + size(t.body)
    raise TypeError(f"Unknown term type: {type(t)}")


def subst(t: Term, x: int, s: Term) -> Term:
    """Substitute term s for variable x in term t (naive, capture-permitting)."""
    if isinstance(t, Var):
        return s if t.name == x else t
    elif isinstance(t, App):
        return App(subst(t.func, x, s), subst(t.arg, x, s))
    elif isinstance(t, Lam):
        if t.var == x:
            return t  # x is shadowed
        return Lam(t.var, subst(t.body, x, s))
    raise TypeError(f"Unknown term type: {type(t)}")


def var_count(x: int, t: Term) -> int:
    """Count occurrences of variable x in term t."""
    if isinstance(t, Var):
        return 1 if t.name == x else 0
    elif isinstance(t, App):
        return var_count(x, t.func) + var_count(x, t.arg)
    elif isinstance(t, Lam):
        return 0 if t.var == x else var_count(x, t.body)
    raise TypeError(f"Unknown term type: {type(t)}")


def redex_count(t: Term) -> int:
    """Count the number of beta-redex positions in a term.

    A redex is an application whose function is a lambda abstraction.

    >>> redex_count(Var(0))
    0
    >>> redex_count(App(Lam(0, Var(0)), Var(1)))
    1
    >>> redex_count(Lam(0, App(Lam(1, Var(1)), Var(0))))
    1
    """
    if isinstance(t, Var):
        return 0
    elif isinstance(t, App):
        if isinstance(t.func, Lam):
            return 1 + redex_count(t.func.body) + redex_count(t.arg)
        return redex_count(t.func) + redex_count(t.arg)
    elif isinstance(t, Lam):
        return redex_count(t.body)
    raise TypeError(f"Unknown term type: {type(t)}")


def branch_complexity(t: Term) -> int:
    """Compute the branching complexity: redex_count + 1.

    This bounds the number of distinct one-step beta-reducts plus identity.

    >>> branch_complexity(Var(0))
    1
    >>> branch_complexity(App(Lam(0, Var(0)), Var(1)))
    2
    """
    return redex_count(t) + 1


def is_affine(t: Term) -> bool:
    """Check if a term is affine (each bound variable occurs at most once).

    >>> is_affine(Lam(0, Var(0)))
    True
    >>> is_affine(Lam(0, App(Var(0), Var(0))))
    False
    """
    if isinstance(t, Var):
        return True
    elif isinstance(t, App):
        return is_affine(t.func) and is_affine(t.arg)
    elif isinstance(t, Lam):
        return var_count(t.var, t.body) <= 1 and is_affine(t.body)
    raise TypeError(f"Unknown term type: {type(t)}")


# --- Successor Enumeration ---

def compute_successors(t: Term) -> List[Term]:
    """Compute all one-step beta-reducts of a term.

    Time complexity: O(size(t))

    >>> compute_successors(App(Lam(0, Var(0)), Lam(1, Var(1))))
    [(λ1. 1)]
    """
    if isinstance(t, Var):
        return []
    elif isinstance(t, App):
        result = []
        if isinstance(t.func, Lam):
            # Head reduction
            result.append(subst(t.func.body, t.func.var, t.arg))
        # Reduce in function position
        for f_prime in compute_successors(t.func):
            result.append(App(f_prime, t.arg))
        # Reduce in argument position
        for a_prime in compute_successors(t.arg):
            result.append(App(t.func, a_prime))
        return result
    elif isinstance(t, Lam):
        return [Lam(t.var, b_prime) for b_prime in compute_successors(t.body)]
    raise TypeError(f"Unknown term type: {type(t)}")


# --- Bounded State-Space Exploration ---

def compute_bounded_states(d: int, t: Term) -> Set[Term]:
    """Compute all terms reachable from t in at most d beta-steps.

    Uses BFS (breadth-first search) up to depth d.

    Time: O(|S_d| * max_successors * d) where |S_d| <= (B+1)^d

    >>> len(compute_bounded_states(0, Var(0)))
    1
    >>> len(compute_bounded_states(1, App(Lam(0, Var(0)), Lam(1, Var(1)))))
    2
    """
    states: Set[Term] = {t}
    frontier = {t}
    for _ in range(d):
        new_frontier: Set[Term] = set()
        for s in frontier:
            for succ in compute_successors(s):
                if succ not in states:
                    states.add(succ)
                    new_frontier.add(succ)
        frontier = new_frontier
        if not frontier:
            break
    return states


def compute_state_growth(t: Term, d: int) -> int:
    """Compute stateGrowth(t, d) = |{u | ReachableWithin(d, t, u)}|.

    >>> compute_state_growth(Var(0), 5)
    1
    """
    return len(compute_bounded_states(d, t))


def state_growth_sequence(t: Term, max_d: int) -> List[int]:
    """Compute the state growth sequence [stateGrowth(t, 0), ..., stateGrowth(t, max_d)].

    More efficient than calling compute_state_growth repeatedly.
    """
    states: Set[Term] = {t}
    frontier = {t}
    result = [1]
    for _ in range(max_d):
        new_frontier: Set[Term] = set()
        for s in frontier:
            for succ in compute_successors(s):
                if succ not in states:
                    states.add(succ)
                    new_frontier.add(succ)
        frontier = new_frontier
        result.append(len(states))
        if not frontier:
            # Fill remaining entries
            while len(result) <= max_d:
                result.append(len(states))
            break
    return result


# --- Random Term Generation ---

def random_term(max_depth: int, max_var: int = 5, p_lam: float = 0.3) -> Term:
    """Generate a random lambda term.

    Args:
        max_depth: Maximum nesting depth
        max_var: Maximum variable name
        p_lam: Probability of generating a lambda at each level
    """
    if max_depth <= 0:
        return Var(random.randint(0, max_var))

    r = random.random()
    if r < 0.4:
        return Var(random.randint(0, max_var))
    elif r < 0.4 + p_lam:
        x = random.randint(0, max_var)
        return Lam(x, random_term(max_depth - 1, max_var, p_lam))
    else:
        return App(
            random_term(max_depth - 1, max_var, p_lam),
            random_term(max_depth - 1, max_var, p_lam)
        )


def random_affine_term(max_depth: int, bound_vars: List[int] = None,
                        next_var: int = 0) -> Term:
    """Generate a random affine lambda term (each bound variable used at most once)."""
    if bound_vars is None:
        bound_vars = []

    if max_depth <= 0:
        if bound_vars and random.random() < 0.6:
            v = random.choice(bound_vars)
            return Var(v)
        return Var(next_var + 100)  # Free variable

    r = random.random()
    if r < 0.3:
        if bound_vars and random.random() < 0.6:
            v = random.choice(bound_vars)
            return Var(v)
        return Var(next_var + 100)
    elif r < 0.55:
        x = next_var
        body = random_affine_term(max_depth - 1, bound_vars + [x], next_var + 1)
        return Lam(x, body)
    else:
        # Split bound vars between func and arg
        random.shuffle(bound_vars)
        mid = len(bound_vars) // 2
        func = random_affine_term(max_depth - 1, bound_vars[:mid], next_var)
        arg = random_affine_term(max_depth - 1, bound_vars[mid:], next_var)
        return App(func, arg)


# --- Example Terms ---

# Identity: λ0. 0
IDENTITY = Lam(0, Var(0))

# Simple redex: (λ0. 0) (λ1. 1)
SIMPLE_REDEX = App(Lam(0, Var(0)), Lam(1, Var(1)))

# Self-application: λ0. (0 0)
SELF_APP = Lam(0, App(Var(0), Var(0)))

# Omega combinator: (λ0. 0 0)(λ0. 0 0)
OMEGA = App(Lam(0, App(Var(0), Var(0))), Lam(0, App(Var(0), Var(0))))

# Church numeral 2: λf. λx. f (f x)
CHURCH_2 = Lam(0, Lam(1, App(Var(0), App(Var(0), Var(1)))))

# Church numeral 3
CHURCH_3 = Lam(0, Lam(1, App(Var(0), App(Var(0), App(Var(0), Var(1))))))


if __name__ == "__main__":
    # Quick demonstration
    print("=== Lambda Calculus State-Space Analysis ===\n")

    examples = [
        ("Identity", IDENTITY),
        ("Simple Redex", SIMPLE_REDEX),
        ("Self-Application", SELF_APP),
        ("Omega", OMEGA),
        ("Church 2", CHURCH_2),
    ]

    for name, term in examples:
        bc = branch_complexity(term)
        aff = is_affine(term)
        succs = len(compute_successors(term))
        sg = state_growth_sequence(term, 5)
        print(f"{name}: {term}")
        print(f"  size={size(term)}, branchComplexity={bc}, affine={aff}")
        print(f"  successors={succs}, growth={sg}")
        print()
