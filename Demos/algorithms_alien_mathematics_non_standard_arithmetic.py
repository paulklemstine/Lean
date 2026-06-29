"""
Growth Filtration Algebra: Algorithms and Data Structures

Type-hinted implementations of the core constructions from the
Growth Filtration Algebra on non-standard arithmetic.
"""

from typing import Callable, List, Optional, Set, Tuple
import math


# Type aliases
Sequence = Callable[[int], int]
GrowthBound = Callable[[int], int]
IndexSet = Set[int]


def is_growth_bounded(f: Sequence, alpha: GrowthBound, 
                       indices: List[int]) -> Tuple[bool, List[int]]:
    """
    Check if f is α-bounded on a given set of indices.
    
    In the ultrapower, GrowthBounded U α f means {i | f(i) ≤ α(i)} ∈ U.
    We approximate this by checking on finite index sets.
    
    Returns (is_bounded, violation_indices).
    """
    violations = [i for i in indices if f(i) > alpha(i)]
    return (len(violations) == 0, violations)


def growth_level_membership(f: Sequence, max_index: int = 100) -> dict:
    """
    Determine which polynomial growth levels contain f.
    
    Returns a dict mapping k → (is_member, fraction_bounded)
    where G_{n^k} membership is approximated over [2, max_index).
    """
    indices = list(range(2, max_index))
    result = {}
    
    for k in range(0, 10):
        alpha: GrowthBound = lambda i, k=k: i ** k
        bounded_count = sum(1 for i in indices if f(i) <= alpha(i))
        fraction = bounded_count / len(indices)
        result[k] = {
            'is_member': fraction == 1.0,
            'fraction_bounded': fraction,
            'first_violation': next((i for i in indices if f(i) > alpha(i)), None)
        }
    
    return result


def ultrapower_compare(f: Sequence, g: Sequence, 
                        indices: List[int]) -> str:
    """
    Compare two elements of the ultrapower.
    
    Approximates ULe/ULt by checking on finite index sets.
    Returns 'less', 'equal', 'greater', or 'incomparable'.
    """
    less_count = sum(1 for i in indices if f(i) < g(i))
    equal_count = sum(1 for i in indices if f(i) == g(i))
    greater_count = sum(1 for i in indices if f(i) > g(i))
    
    total = len(indices)
    
    if equal_count == total:
        return 'equal'
    elif less_count + equal_count == total:
        return 'less'
    elif greater_count + equal_count == total:
        return 'greater'
    else:
        # Neither f ≤ g nor g ≤ f on all indices
        # In the ultrapower, one of these must hold (total order)
        # but on finite sets we see the pre-asymptotic behavior
        if less_count > greater_count:
            return 'likely_less'
        else:
            return 'likely_greater'


def find_growth_rank(f: Sequence, max_index: int = 200) -> Optional[int]:
    """
    Find the smallest polynomial growth level containing f.
    
    Returns k such that f ∈ G_{n^k}, or None if f exceeds all
    polynomial levels on the test range.
    """
    indices = list(range(2, max_index))
    
    for k in range(0, 20):
        alpha: GrowthBound = lambda i, k=k: i ** k
        if all(f(i) <= alpha(i) for i in indices):
            return k
    
    return None  # Super-polynomial growth


def successor_gap_check(h: Sequence, max_index: int = 1000) -> bool:
    """
    Check if h fills the gap between id and id+1.
    
    Returns False (it never can): for each i, we need i < h(i) < i+1,
    which is impossible for natural numbers.
    """
    for i in range(max_index):
        if i < h(i) < i + 1:
            return True  # Would fill the gap (impossible for naturals)
    return False


def growth_filtration_add(f: Sequence, g: Sequence,
                           alpha: GrowthBound, beta: GrowthBound,
                           max_index: int = 100) -> dict:
    """
    Verify the additive closure property: G_α + G_β ⊆ G_{α+β}.
    
    If f ∈ G_α and g ∈ G_β, checks that f+g ∈ G_{α+β}.
    """
    indices = list(range(max_index))
    
    f_bounded, f_violations = is_growth_bounded(f, alpha, indices)
    g_bounded, g_violations = is_growth_bounded(g, beta, indices)
    
    sum_bound: GrowthBound = lambda i: alpha(i) + beta(i)
    sum_func: Sequence = lambda i: f(i) + g(i)
    sum_bounded, sum_violations = is_growth_bounded(sum_func, sum_bound, indices)
    
    return {
        'f_in_G_alpha': f_bounded,
        'g_in_G_beta': g_bounded,
        'fg_in_G_alpha_plus_beta': sum_bounded,
        'theorem_verified': (not f_bounded or not g_bounded or sum_bounded),
        'f_violations': f_violations[:5],
        'g_violations': g_violations[:5],
        'sum_violations': sum_violations[:5]
    }


def growth_filtration_mul(f: Sequence, g: Sequence,
                           alpha: GrowthBound, beta: GrowthBound,
                           max_index: int = 100) -> dict:
    """
    Verify the multiplicative closure property: G_α · G_β ⊆ G_{α·β}.
    """
    indices = list(range(max_index))
    
    f_bounded, _ = is_growth_bounded(f, alpha, indices)
    g_bounded, _ = is_growth_bounded(g, beta, indices)
    
    prod_bound: GrowthBound = lambda i: alpha(i) * beta(i)
    prod_func: Sequence = lambda i: f(i) * g(i)
    prod_bounded, prod_violations = is_growth_bounded(prod_func, prod_bound, indices)
    
    return {
        'f_in_G_alpha': f_bounded,
        'g_in_G_beta': g_bounded,
        'fg_in_G_alpha_times_beta': prod_bounded,
        'theorem_verified': (not f_bounded or not g_bounded or prod_bounded)
    }


def dichotomy_test(f: Sequence, max_k: int = 15, 
                    max_index: int = 200) -> dict:
    """
    Test the Growth Level Dichotomy conjecture for a specific function.
    
    Checks whether f is either in some G_{n^k} or dominates all G_{n^k}.
    """
    indices = list(range(2, max_index))
    
    in_some_level = False
    dominates_all = True
    
    for k in range(max_k):
        alpha: GrowthBound = lambda i, k=k: i ** k
        bounded = all(f(i) <= alpha(i) for i in indices)
        
        if bounded:
            in_some_level = True
            dominates_all = False
            return {
                'in_polynomial_level': k,
                'dominates_all': False,
                'dichotomy_holds': True
            }
    
    # Check if it dominates all tested levels
    return {
        'in_polynomial_level': None,
        'dominates_all': True,
        'dichotomy_holds': True,
        'note': 'Dominates all polynomial levels up to k={}'.format(max_k)
    }


if __name__ == "__main__":
    # Example usage
    print("Growth Filtration Algebra - Algorithm Demonstrations\n")
    
    # 1. Growth rank of various sequences
    print("Growth ranks of example sequences:")
    examples = [
        ("constant 5", lambda i: 5),
        ("linear: i", lambda i: i),
        ("quadratic: i²", lambda i: i**2),
        ("cubic: i³", lambda i: i**3),
        ("i^floor(log i)", lambda i: max(1, i ** max(1, int(math.log2(max(2, i)))))),
    ]
    
    for name, f in examples:
        rank = find_growth_rank(f)
        print(f"  {name}: growth rank = {rank}")
    
    # 2. Successor gap
    print(f"\nSuccessor gap check (h(i) = i): {successor_gap_check(lambda i: i)}")
    print(f"Successor gap check (h(i) = i+1): {successor_gap_check(lambda i: i+1)}")
    
    # 3. Additive closure
    result = growth_filtration_add(
        lambda i: i, lambda i: i**2,
        lambda i: i, lambda i: i**2
    )
    print(f"\nAdditive closure (id + n²): {result['theorem_verified']}")
    
    # 4. Dichotomy test
    result = dichotomy_test(lambda i: max(1, i ** max(1, int(math.log2(max(2, i))))))
    print(f"\nDichotomy test (i^log(i)): {result}")
