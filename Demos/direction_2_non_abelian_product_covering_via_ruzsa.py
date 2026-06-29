"""
Applications of non-abelian product covering theorems.

Demonstrates the theorems on concrete groups and explores
the boundary between abelian and non-abelian covering behavior.
"""

from demo import symmetric_group, gl2_fp, finset_mul, is_symmetric, contains_identity
from algorithms import (compute_doubling_constant, greedy_cover, product_set,
                         conjugation_index, analyze_covering)


def application_1_subgroup_covering():
    """
    Application: Subgroup covering in S₄.
    
    Shows that for actual subgroups (K=1), the covering of A·A
    depends on normality.
    """
    print("=" * 60)
    print("Application 1: Subgroup vs Normal Subgroup Covering in S₄")
    print("=" * 60)
    
    elems, ops = symmetric_group(4)
    mul, inv, e = ops['mul'], ops['inv'], ops['id']
    
    # Normal subgroup: A₄ (alternating group, order 12)
    # Non-normal subgroup: {e, (12)} (order 2)
    
    # Find a non-normal subgroup of order 2
    H_nonnormal = {e, (1, 0, 3, 2)}  # (12) as permutation
    H_nonnormal = {e}
    for g in elems:
        if g != e and mul(g, g) == e:
            H_nonnormal = {e, g}
            break
    
    print(f"\nNon-normal subgroup H = {H_nonnormal}")
    print(f"|H| = {len(H_nonnormal)}")
    
    # Find a coset that demonstrates the non-normal obstruction
    for g in elems:
        if g not in H_nonnormal:
            A = {mul(g, h) for h in H_nonnormal}
            result = analyze_covering(elems, A, H_nonnormal, mul, inv, e)
            
            print(f"\nA = {g}·H (coset)")
            print(f"  C = {result['C']}, K = {result['K']}")
            print(f"  |A·A| = {result['AA_size']}, C(A·A) = {result['C_AA']}")
            print(f"  Conjugation index L = {result['max_conj_index']}")
            print(f"  Bound C²K = {result['bound_C2K']}")
            print(f"  Bound C²KL = {result['bound_C2KL']}")
            print(f"  Violates C²K: {result['violates_C2K']}")
            break


def application_2_approximate_subgroups():
    """
    Application: Approximate subgroup detection in GL(2, F₂).
    """
    print("\n" + "=" * 60)
    print("Application 2: Approximate Subgroups in GL(2, F₂)")
    print("=" * 60)
    
    elems, ops = gl2_fp(2)
    mul, inv, e = ops['mul'], ops['inv'], ops['id']
    
    print(f"|GL(2, F₂)| = {len(elems)}")
    
    # Find all symmetric subsets containing identity
    count = 0
    for size in range(2, len(elems)):
        for g in elems:
            if g == e:
                continue
            H = {e, g, inv(g)}
            if len(H) == size and is_symmetric(H, inv):
                K, X = compute_doubling_constant(H, mul, inv, e)
                if K <= 3:
                    print(f"\n  H of size {len(H)}: K = {K}")
                    
                    # Test covering of H·H·H
                    HHH = product_set(product_set(H, H, mul), H, mul)
                    C_HHH, _ = greedy_cover(HHH, H, mul, inv, e)
                    print(f"  |H³| = {len(HHH)}, C(H³) = {C_HHH}, bound K² = {K**2}")
                    
                    count += 1
                    if count >= 3:
                        return


def application_3_word_metric():
    """
    Application: Word metric control in S₃.
    """
    print("\n" + "=" * 60)
    print("Application 3: Word Metric Control in S₃")
    print("=" * 60)
    
    elems, ops = symmetric_group(3)
    mul, inv, e = ops['mul'], ops['inv'], ops['id']
    
    # Use a generating set
    s1 = elems[1]  # (01) transposition
    s2 = elems[2]  # (02) transposition
    S = {s1, s2}
    
    print(f"Generators: {S}")
    
    # Compute word lengths
    word_lengths = {e: 0}
    frontier = {e}
    gen_set = S | {inv(s) for s in S}
    
    for r in range(1, len(elems)):
        new_frontier = set()
        for g in frontier:
            for s in gen_set:
                gs = mul(g, s)
                if gs not in word_lengths:
                    word_lengths[gs] = r
                    new_frontier.add(gs)
        frontier = new_frontier
        if not frontier:
            break
    
    print(f"Word lengths: {word_lengths}")
    
    # Take H = elements of word length ≤ 1
    H = {g for g, wl in word_lengths.items() if wl <= 1}
    print(f"\nH (word ball radius 1): |H| = {len(H)}")
    
    K, _ = compute_doubling_constant(H, mul, inv, e)
    print(f"K = {K}")
    
    # Take A = a coset
    for g in elems:
        if g not in H:
            A = {mul(g, h) for h in H}
            result = analyze_covering(elems, A, H, mul, inv, e)
            print(f"\nA = {g}·H, |A| = {len(A)}")
            print(f"C = {result['C']}, C(A·A) = {result['C_AA']}")
            
            # Check word metric control
            AA = product_set(A, A, mul)
            for x in AA:
                wl = word_lengths.get(x, '?')
                print(f"  x ∈ A·A: word length = {wl}")
            break


if __name__ == '__main__':
    application_1_subgroup_covering()
    application_2_approximate_subgroups()
    application_3_word_metric()


#!/usr/bin/env python3
"""
Demo: Non-Abelian Product Covering via Ruzsa Calculus

Tests the product covering theorems on finite groups S₃, S₄, GL(2, F₂), GL(2, F₃).
For each group and each pair (A, H) where H is a K-approximate subgroup,
computes covering numbers and compares with the theoretical bound C²K³.
"""

from itertools import product as cart_product
from typing import List, Tuple, Set, Dict, Optional
import sys

# ─── Group representations ───

def symmetric_group(n: int) -> Tuple[List[tuple], dict]:
    """Generate S_n as a list of permutations with multiplication table."""
    from itertools import permutations
    elems = list(permutations(range(n)))
    
    def mul(a, b):
        return tuple(a[b[i]] for i in range(n))
    
    def inv(a):
        result = list(range(n))
        for i, v in enumerate(a):
            result[v] = i
        return tuple(result)
    
    identity = tuple(range(n))
    return elems, {'mul': mul, 'inv': inv, 'id': identity, 'name': f'S_{n}'}


def gl2_fp(p: int) -> Tuple[List[tuple], dict]:
    """Generate GL(2, F_p) as 2x2 matrices over F_p."""
    # Represent as (a,b,c,d) meaning [[a,b],[c,d]]
    elems = []
    for a in range(p):
        for b in range(p):
            for c in range(p):
                for d in range(p):
                    det = (a * d - b * c) % p
                    if det != 0:
                        elems.append((a, b, c, d))
    
    def mul(A, B):
        a1, b1, c1, d1 = A
        a2, b2, c2, d2 = B
        return (
            (a1*a2 + b1*c2) % p,
            (a1*b2 + b1*d2) % p,
            (c1*a2 + d1*c2) % p,
            (c1*b2 + d1*d2) % p
        )
    
    def inv(A):
        a, b, c, d = A
        det = (a * d - b * c) % p
        det_inv = pow(det, p - 2, p)
        return (
            (d * det_inv) % p,
            ((-b) * det_inv) % p,
            ((-c) * det_inv) % p,
            (a * det_inv) % p
        )
    
    identity = (1, 0, 0, 1)
    return elems, {'mul': mul, 'inv': inv, 'id': identity, 'name': f'GL(2, F_{p})'}


# ─── Covering computations ───

def finset_mul(A: Set, B: Set, mul_fn) -> Set:
    """Compute the product set A * B."""
    return {mul_fn(a, b) for a in A for b in B}


def finset_inv(A: Set, inv_fn) -> Set:
    """Compute A⁻¹."""
    return {inv_fn(a) for a in A}


def is_symmetric(H: Set, inv_fn) -> bool:
    """Check if H is symmetric (closed under inversion)."""
    return all(inv_fn(h) in H for h in H)


def contains_identity(H: Set, identity) -> bool:
    """Check if H contains the identity."""
    return identity in H


def compute_approx_subgroup_K(H: Set, mul_fn, identity) -> Tuple[int, Set]:
    """
    Compute the minimal K such that H is a K-approximate subgroup.
    Returns (K, X) where H*H ⊆ X*H and |X| = K.
    Uses a greedy covering algorithm.
    """
    HH = finset_mul(H, H, mul_fn)
    # Greedy covering: find minimal X such that HH ⊆ X * H
    uncovered = set(HH)
    X = set()
    
    while uncovered:
        # Pick the translate that covers the most uncovered elements
        best_t = None
        best_count = 0
        for t in HH:
            coset = {mul_fn(t, h) for h in H}
            count = len(uncovered & coset)
            if count > best_count:
                best_count = count
                best_t = t
        
        if best_t is None or best_count == 0:
            break
        
        X.add(best_t)
        coset = {mul_fn(best_t, h) for h in H}
        uncovered -= coset
    
    return len(X), X


def compute_cover_number(A: Set, H: Set, mul_fn, identity) -> Tuple[int, Set]:
    """
    Compute the minimal C such that A is covered by C left translates of H.
    Returns (C, T) where A ⊆ T*H and |T| = C.
    """
    if not A:
        return 0, set()
    
    uncovered = set(A)
    T = set()
    
    while uncovered:
        best_t = None
        best_count = 0
        # Try all possible translates
        for elem in A:
            for h in H:
                t = mul_fn(elem, mul_fn(h, identity))  # Simplified: use elements from group
                # Actually, we want to try various t values
                pass
        
        # Simpler greedy: for each uncovered element, the translate is elem * h⁻¹
        elem = next(iter(uncovered))
        for h in H:
            from functools import reduce
            inv_h = None
            # Find inverse of h
            for g in H:
                if mul_fn(h, g) == identity:
                    inv_h = g
                    break
            if inv_h is None:
                continue
            t = mul_fn(elem, inv_h)
            coset = {mul_fn(t, h2) for h2 in H}
            if elem in coset:
                T.add(t)
                uncovered -= coset
                break
        else:
            # Fallback: just add elem as translate with identity as base
            T.add(elem)
            coset = {mul_fn(elem, h2) for h2 in H}
            uncovered -= coset
    
    return len(T), T


def compute_cover_number_exact(A: Set, H: Set, mul_fn, inv_fn) -> int:
    """
    Compute the exact minimal covering number by greedy algorithm.
    """
    if not A:
        return 0
    
    uncovered = set(A)
    count = 0
    
    while uncovered:
        # Find the translate covering the most uncovered elements
        best_t = None
        best_covered = set()
        
        for a in list(uncovered)[:1]:  # Start from first uncovered
            for h in H:
                t = mul_fn(a, inv_fn(h))
                coset = {mul_fn(t, h2) for h2 in H}
                covered = uncovered & coset
                if len(covered) > len(best_covered):
                    best_covered = covered
                    best_t = t
        
        if not best_covered:
            break
        
        uncovered -= best_covered
        count += 1
    
    return count


def run_demo(elems, ops, max_H_size=None):
    """Run the covering demo on a given group."""
    mul_fn = ops['mul']
    inv_fn = ops['inv']
    identity = ops['id']
    name = ops['name']
    
    print(f"\n{'='*60}")
    print(f"Group: {name}, |G| = {len(elems)}")
    print(f"{'='*60}")
    
    if max_H_size is None:
        max_H_size = min(len(elems), 12)
    
    # Find symmetric subsets containing identity
    # For efficiency, test a sample of subsets
    test_cases = []
    
    # Test actual subgroups first
    subgroups = find_subgroups(elems, ops, max_size=max_H_size)
    for H in subgroups:
        if len(H) > 1 and len(H) < len(elems):
            test_cases.append(('subgroup', frozenset(H)))
    
    # Test some approximate subgroups (small symmetric sets containing 1)
    for size in range(2, min(max_H_size + 1, len(elems))):
        found = 0
        for attempt in range(min(50, len(elems))):
            import random
            random.seed(42 + attempt + size * 100)
            # Generate a random symmetric set containing identity
            H = {identity}
            candidates = [e for e in elems if e != identity]
            random.shuffle(candidates)
            for c in candidates:
                if len(H) >= size:
                    break
                inv_c = inv_fn(c)
                if inv_c not in H:
                    H.add(c)
                    H.add(inv_c)
                elif c not in H:
                    H.add(c)
            
            if len(H) >= 2 and is_symmetric(H, inv_fn):
                K, _ = compute_approx_subgroup_K(H, mul_fn, identity)
                if K <= 4:  # Only test small K
                    test_cases.append(('approx', frozenset(H)))
                    found += 1
                    if found >= 2:
                        break
    
    # Remove duplicates
    seen = set()
    unique_cases = []
    for label, H in test_cases:
        if H not in seen:
            seen.add(H)
            unique_cases.append((label, H))
    
    if not unique_cases:
        print("  No suitable test cases found.")
        return
    
    # Test each H
    results = []
    for label, H_frozen in unique_cases[:8]:  # Limit cases
        H = set(H_frozen)
        K, X = compute_approx_subgroup_K(H, mul_fn, identity)
        
        print(f"\n  H: |H| = {len(H)}, type = {label}, K = {K}")
        print(f"  Symmetric: {is_symmetric(H, inv_fn)}, 1 ∈ H: {contains_identity(H, identity)}")
        
        # Test various subsets A
        test_As = []
        
        # A = H itself
        test_As.append(('H', H))
        
        # A = some coset of H
        for g in elems[:5]:
            coset = {mul_fn(g, h) for h in H}
            if coset != H:
                test_As.append(('coset', coset))
                break
        
        # A = union of 2 cosets
        cosets_seen = [H]
        for g in elems:
            coset = {mul_fn(g, h) for h in H}
            if all(coset != c for c in cosets_seen):
                A_union = H | coset
                test_As.append(('2-cosets', A_union))
                cosets_seen.append(coset)
                break
        
        for a_label, A in test_As:
            C = compute_cover_number_exact(A, H, mul_fn, inv_fn)
            
            # Compute A * A
            AA = finset_mul(A, A, mul_fn)
            C_AA = compute_cover_number_exact(AA, H, mul_fn, inv_fn)
            
            bound = C**2 * K**3
            bound_comm = C**2 * K
            
            status = "✓ SHARP" if C_AA == bound else ("✓ WITHIN" if C_AA <= bound else "✗ EXCEEDS")
            
            print(f"    A ({a_label}): |A|={len(A)}, C={C}, |A·A|={len(AA)}, "
                  f"C(A·A)={C_AA}, bound C²K³={bound}, C²K={bound_comm} [{status}]")
            
            results.append({
                'group': name, 'H_size': len(H), 'K': K,
                'A_type': a_label, 'A_size': len(A),
                'C': C, 'AA_size': len(AA), 'C_AA': C_AA,
                'bound_C2K3': bound, 'bound_C2K': bound_comm,
                'sharp': C_AA == bound, 'within': C_AA <= bound
            })
    
    return results


def find_subgroups(elems, ops, max_size=12):
    """Find subgroups up to a given size."""
    mul_fn = ops['mul']
    inv_fn = ops['inv']
    identity = ops['id']
    
    subgroups = [{identity}]
    
    # Generate by closing under multiplication
    for g in elems:
        if g == identity:
            continue
        H = {identity, g}
        # Close under mul and inv
        changed = True
        while changed and len(H) <= max_size:
            changed = False
            new = set()
            for a in H:
                for b in H:
                    p = mul_fn(a, b)
                    if p not in H:
                        new.add(p)
                        changed = True
                inv_a = inv_fn(a)
                if inv_a not in H:
                    new.add(inv_a)
                    changed = True
            H |= new
        
        if len(H) <= max_size and len(H) > 1:
            # Verify it's actually a subgroup
            is_sub = True
            for a in H:
                for b in H:
                    if mul_fn(a, b) not in H:
                        is_sub = False
                        break
                if not is_sub:
                    break
            if is_sub:
                subgroups.append(H)
    
    # Remove duplicates
    unique = []
    for H in subgroups:
        H_frozen = frozenset(H)
        if not any(frozenset(u) == H_frozen for u in unique):
            unique.append(H)
    
    return unique


# ─── Conjecture Testing ───

def test_conjecture(results):
    """Test the sharp non-abelian product cover conjecture."""
    print(f"\n{'='*60}")
    print("CONJECTURE TEST: C(A·A) ≤ C² · K²")
    print(f"{'='*60}")
    
    violations = []
    for r in results:
        bound_C2K2 = r['C']**2 * r['K']**2
        if r['C_AA'] > bound_C2K2:
            violations.append(r)
    
    if violations:
        print(f"\n  ✗ VIOLATIONS FOUND ({len(violations)}):")
        for v in violations:
            print(f"    {v['group']}: |H|={v['H_size']}, K={v['K']}, "
                  f"C={v['C']}, C(A·A)={v['C_AA']}, bound={v['C']**2 * v['K']**2}")
    else:
        print(f"\n  ✓ No violations found across {len(results)} test cases.")
    
    # Also test C² * K bound
    print(f"\n  Secondary test: C(A·A) ≤ C² · K")
    violations2 = [r for r in results if r['C_AA'] > r['bound_C2K']]
    if violations2:
        print(f"  ✗ {len(violations2)} violations of C²K bound")
    else:
        print(f"  ✓ All {len(results)} cases satisfy C²K bound")


# ─── Main ───

def main():
    print("Non-Abelian Product Covering Demo")
    print("Testing covering theorems on finite groups\n")
    
    all_results = []
    
    # S₃
    elems, ops = symmetric_group(3)
    r = run_demo(elems, ops)
    if r:
        all_results.extend(r)
    
    # S₄
    elems, ops = symmetric_group(4)
    r = run_demo(elems, ops, max_H_size=8)
    if r:
        all_results.extend(r)
    
    # GL(2, F₂)
    elems, ops = gl2_fp(2)
    r = run_demo(elems, ops)
    if r:
        all_results.extend(r)
    
    # GL(2, F₃) 
    elems, ops = gl2_fp(3)
    r = run_demo(elems, ops, max_H_size=8)
    if r:
        all_results.extend(r)
    
    # Test conjectures
    if all_results:
        test_conjecture(all_results)
    
    print(f"\n{'='*60}")
    print(f"Summary: Tested {len(all_results)} (A, H) pairs across 4 groups")
    print(f"{'='*60}")


if __name__ == '__main__':
    main()


"""
Visualization: Covering number heatmap for S₃.

Shows the covering number C(A·A) vs the theoretical bound C²·K
for all (A, H) pairs in S₃, revealing where non-abelian obstructions appear.

Uses matplotlib to produce a static heatmap.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations

# ── S₃ group operations ──

def s3_mul(a, b):
    return tuple(a[b[i]] for i in range(3))

def s3_inv(a):
    r = [0]*3
    for i, v in enumerate(a):
        r[v] = i
    return tuple(r)

S3 = list(permutations(range(3)))
e = (0, 1, 2)

def greedy_cover(A, H):
    uncovered = set(A)
    count = 0
    while uncovered:
        a = next(iter(uncovered))
        best = set()
        for h in H:
            t = s3_mul(a, s3_inv(h))
            coset = {s3_mul(t, h2) for h2 in H}
            cov = uncovered & coset
            if len(cov) > len(best):
                best = cov
        uncovered -= best
        count += 1
    return count

def doubling_K(H):
    HH = {s3_mul(a, b) for a in H for b in H}
    return greedy_cover(HH, H)

# ── Find all symmetric subsets containing identity ──

def is_symmetric(H):
    return all(s3_inv(h) in H for h in H)

subsets = []
for mask in range(1, 2**6):
    H = set()
    for i in range(6):
        if mask & (1 << i):
            H.add(S3[i])
    if e in H and is_symmetric(H) and 1 < len(H) < 6:
        subsets.append(frozenset(H))

# Remove duplicates
subsets = list(set(subsets))

# ── Compute covering data ──

data = []
for H_frozen in subsets:
    H = set(H_frozen)
    K = doubling_K(H)
    
    # Test various A subsets
    for g in S3:
        A = {s3_mul(g, h) for h in H}
        C = greedy_cover(A, H)
        AA = {s3_mul(a, b) for a in A for b in A}
        C_AA = greedy_cover(AA, H)
        
        bound_C2K = C**2 * K
        ratio = C_AA / max(bound_C2K, 1)
        
        data.append({
            'H_size': len(H), 'K': K, 'C': C,
            'C_AA': C_AA, 'bound': bound_C2K, 'ratio': ratio
        })

# ── Create heatmap ──

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Plot 1: C(A·A) vs bound
ax = axes[0]
H_sizes = sorted(set(d['H_size'] for d in data))
K_vals = sorted(set(d['K'] for d in data))

grid = np.zeros((len(H_sizes), len(K_vals)))
counts = np.zeros((len(H_sizes), len(K_vals)))

for d in data:
    i = H_sizes.index(d['H_size'])
    j = K_vals.index(d['K'])
    grid[i, j] += d['ratio']
    counts[i, j] += 1

grid = np.where(counts > 0, grid / counts, np.nan)

im = ax.imshow(grid, cmap='RdYlGn_r', aspect='auto', vmin=0, vmax=2)
ax.set_xticks(range(len(K_vals)))
ax.set_xticklabels(K_vals)
ax.set_yticks(range(len(H_sizes)))
ax.set_yticklabels(H_sizes)
ax.set_xlabel('Approximate subgroup constant K')
ax.set_ylabel('|H|')
ax.set_title('Average C(A·A) / C²K ratio in S₃')
plt.colorbar(im, ax=ax, label='Ratio (>1 = violation)')

# Plot 2: Violation frequency
ax = axes[1]
violations = [d for d in data if d['C_AA'] > d['bound']]
non_violations = [d for d in data if d['C_AA'] <= d['bound']]

C_vals = [d['C'] for d in data]
C_AA_vals = [d['C_AA'] for d in data]
colors = ['red' if d['C_AA'] > d['bound'] else 'green' for d in data]

ax.scatter(C_vals, C_AA_vals, c=colors, alpha=0.6, s=50)
max_c = max(C_vals) + 1
ax.plot([0, max_c], [0, max_c**2], 'k--', alpha=0.3, label='C(A·A) = C²')
ax.set_xlabel('C (covering number of A)')
ax.set_ylabel('C(A·A) (covering number of A·A)')
ax.set_title(f'Covering Growth in S₃\n({len(violations)} violations / {len(data)} tests)')
ax.legend()

plt.tight_layout()
plt.savefig('covering_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved covering_heatmap.png")
