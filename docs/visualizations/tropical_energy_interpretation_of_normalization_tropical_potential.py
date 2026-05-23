#!/usr/bin/env python3
"""
Algorithms for the Tropical Energy Interpretation of Normalization.

Implements:
1. Tropical potential computation (O(n) in term size)
2. Parameterized potential evaluation
3. Affine β-normalization with energy tracking
4. Bounded term enumeration with potential census
5. Weight profile search for universal dissipativity
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional, Callable
import itertools


# ─── Term Representation ────────────────────────────────────────────────

@dataclass(frozen=True)
class Var:
    index: int

@dataclass(frozen=True)
class Lam:
    body: 'Tm'

@dataclass(frozen=True)
class App:
    fun: 'Tm'
    arg: 'Tm'

Tm = Var | Lam | App


# ─── Core Operations ────────────────────────────────────────────────────

def lift(c: int, t: Tm) -> Tm:
    """Lift free variables >= c by 1. O(n) time."""
    match t:
        case Var(n): return Var(n if n < c else n + 1)
        case Lam(body): return Lam(lift(c + 1, body))
        case App(f, a): return App(lift(c, f), lift(c, a))

def subst_n(n: int, s: Tm, t: Tm) -> Tm:
    """Substitute variable n with s in t. O(n * m) time where m = |s|."""
    match t:
        case Var(m):
            if m < n: return Var(m)
            elif m == n: return s
            else: return Var(m - 1)
        case Lam(body): return Lam(subst_n(n + 1, lift(0, s), body))
        case App(f, a): return App(subst_n(n, s, f), subst_n(n, s, a))

def subst_top(s: Tm, t: Tm) -> Tm:
    """Top-level substitution: t[0 := s]. O(|t| * |s|) time."""
    return subst_n(0, s, t)

def occ_n(n: int, t: Tm) -> int:
    """Count occurrences of variable n. O(|t|) time."""
    match t:
        case Var(m): return 1 if m == n else 0
        case Lam(body): return occ_n(n + 1, body)
        case App(f, a): return occ_n(n, f) + occ_n(n, a)

def term_size(t: Tm) -> int:
    """Number of nodes. O(|t|) time."""
    match t:
        case Var(_): return 1
        case Lam(body): return 1 + term_size(body)
        case App(f, a): return 1 + term_size(f) + term_size(a)


# ─── Algorithm 1: Tropical Potential ────────────────────────────────────

def tropical_potential(t: Tm) -> int:
    """
    Compute the tropical potential (product interpretation).

    Algorithm: Single bottom-up tree traversal.
    Time complexity: O(|t|) arithmetic operations.
    Space complexity: O(depth(t)) stack space.

    Properties (formally verified):
    - tropical_potential(t) >= 2 for all t
    - tropical_potential(lift c t) = tropical_potential(t)
    - tropical_potential(subst_n n s t) = potential_with(pot(s), n, t)
    """
    match t:
        case Var(_): return 2
        case Lam(body): return tropical_potential(body) + 1
        case App(f, a): return tropical_potential(f) * tropical_potential(a)


# ─── Algorithm 2: Parameterized Potential ───────────────────────────────

def potential_with(v: int, n: int, t: Tm) -> int:
    """
    Evaluate the potential polynomial at variable n = v.

    The parameterized potential treats variable n as having weight v
    instead of the default weight 2. This is the key tool for
    analyzing substitution effects.

    Time complexity: O(|t|)
    """
    match t:
        case Var(m): return v if m == n else 2
        case Lam(body): return potential_with(v, n + 1, body) + 1
        case App(f, a): return potential_with(v, n, f) * potential_with(v, n, a)


# ─── Algorithm 3: Affine Normalizer with Energy Tracking ───────────────

def affine_normalize(t: Tm, max_steps: int = 1000) -> list[tuple[Tm, int, int]]:
    """
    Normalize a term using affine β-reduction, tracking energy at each step.

    Returns: list of (term, potential, energy_drop) tuples.

    The algorithm performs leftmost affine β-reduction: at each step,
    it finds the leftmost β-redex where variable 0 occurs at most once
    in the body, and contracts it.

    Time complexity per step: O(|t|) for finding redex + O(|t|*|s|) for substitution
    Total: O(Φ(t₀) * |t₀|²) worst case (bounded by initial potential)
    """
    trace = [(t, tropical_potential(t), 0)]

    for _ in range(max_steps):
        result = _affine_step(t)
        if result is None:
            break
        pot_before = tropical_potential(t)
        t = result
        pot_after = tropical_potential(t)
        trace.append((t, pot_after, pot_before - pot_after))

    return trace

def _affine_step(t: Tm) -> Optional[Tm]:
    """Find and contract the leftmost affine β-redex."""
    match t:
        case App(Lam(body), arg):
            if occ_n(0, body) <= 1:
                return subst_top(arg, body)
            # Try reducing inside the non-affine redex
            r = _affine_step(Lam(body))
            if r is not None:
                return App(r, arg)
            r = _affine_step(arg)
            if r is not None:
                return App(Lam(body), r)
            return None
        case App(f, a):
            r = _affine_step(f)
            if r is not None: return App(r, a)
            r = _affine_step(a)
            if r is not None: return App(f, r)
            return None
        case Lam(body):
            r = _affine_step(body)
            if r is not None: return Lam(r)
            return None
        case _:
            return None


# ─── Algorithm 4: Bounded Term Census ───────────────────────────────────

def potential_census(max_size: int = 6, num_vars: int = 2) -> dict[int, int]:
    """
    Enumerate all terms up to a given size and compute potential distribution.

    Returns: dict mapping potential values to term counts.

    Time complexity: O(C^max_size) where C is the Catalan-like growth constant.
    """
    census: dict[int, int] = {}
    for t in _enum_terms(max_size, num_vars):
        pot = tropical_potential(t)
        census[pot] = census.get(pot, 0) + 1
    return census

def _enum_terms(max_size: int, num_vars: int) -> list[Tm]:
    """Enumerate terms of exact size up to max_size."""
    if max_size <= 0:
        return []
    result = [Var(i) for i in range(num_vars)]
    if max_size <= 1:
        return result
    for t in _enum_terms(max_size - 1, num_vars + 1):
        result.append(Lam(t))
    for s1 in range(1, max_size - 1):
        s2 = max_size - 1 - s1
        for f in _enum_terms(s1, num_vars):
            for a in _enum_terms(s2, num_vars):
                result.append(App(f, a))
    return result


# ─── Algorithm 5: Weight Profile Search ─────────────────────────────────

def search_weight_profile(
    var_weight_range: range = range(1, 6),
    lam_bonus_range: range = range(0, 4),
    app_mode: str = "multiplicative",
    max_term_size: int = 5,
) -> list[dict]:
    """
    Search for weight profiles that give universal β-dissipativity.

    Tries different variable weights and lambda bonuses, checking whether
    the resulting potential strictly decreases for ALL β-redexes up to
    the given term size.

    Returns: list of successful weight profiles with statistics.
    """
    results = []

    for var_w in var_weight_range:
        for lam_b in lam_bonus_range:
            def custom_pot(t: Tm, vw=var_w, lb=lam_b) -> int:
                match t:
                    case Var(_): return vw
                    case Lam(body): return custom_pot(body) + lb + 1
                    case App(f, a):
                        pf, pa = custom_pot(f), custom_pot(a)
                        return pf * pa if app_mode == "multiplicative" else pf + pa + 1

            violations = 0
            total = 0
            for t in _enum_terms(max_term_size, 2):
                if not isinstance(t, App) or not isinstance(t.fun, Lam):
                    continue
                body, arg = t.fun.body, t.arg
                if occ_n(0, body) > 1:
                    continue
                total += 1
                before = custom_pot(t)
                after = custom_pot(subst_top(arg, body))
                if after >= before:
                    violations += 1

            results.append({
                'var_weight': var_w,
                'lam_bonus': lam_b + 1,
                'app_mode': app_mode,
                'total_tested': total,
                'violations': violations,
                'universal': violations == 0,
            })

    return results


# ─── Main ────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Potential Census (sizes 1-5) ===")
    census = potential_census(5)
    for pot in sorted(census.keys())[:10]:
        print(f"  Φ = {pot:4d}: {census[pot]:4d} terms")

    print("\n=== Weight Profile Search ===")
    profiles = search_weight_profile()
    successes = [p for p in profiles if p['universal']]
    print(f"  Tested {len(profiles)} weight profiles")
    print(f"  Universal dissipativity: {len(successes)} profiles")
    for p in successes[:5]:
        print(f"    var_w={p['var_weight']}, lam_b={p['lam_bonus']}, "
              f"tested={p['total_tested']}")

    print("\n=== Normalization Trace ===")
    # (λ.(λ.x₁)) x₀ x₁ — K combinator
    t = App(App(Lam(Lam(Var(1))), Var(0)), Var(1))
    trace = affine_normalize(t)
    for term, pot, drop in trace:
        print(f"  Φ={pot:4d}  ΔΦ={-drop if drop else '':>4}  {term}")
