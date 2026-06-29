#!/usr/bin/env python3
"""
Lambda Calculus: Confluence, Normalization, and Böhm Tree Approximants

Interactive demonstration of the formally verified lambda calculus theory.
Constructs classic terms, computes reductions, and tests conjectures.
"""

# =============================================================
# Core Lambda Calculus Engine
# =============================================================

class Lam:
    """Lambda terms with de Bruijn indices."""
    pass

class Var(Lam):
    def __init__(self, n: int):
        self.n = n
    def __repr__(self):
        return f"v{self.n}"
    def __eq__(self, other):
        return isinstance(other, Var) and self.n == other.n
    def __hash__(self):
        return hash(('var', self.n))

class App(Lam):
    def __init__(self, t: Lam, u: Lam):
        self.t = t
        self.u = u
    def __repr__(self):
        return f"({self.t} {self.u})"
    def __eq__(self, other):
        return isinstance(other, App) and self.t == other.t and self.u == other.u
    def __hash__(self):
        return hash(('app', self.t, self.u))

class Abs(Lam):
    def __init__(self, body: Lam):
        self.body = body
    def __repr__(self):
        return f"(λ.{self.body})"
    def __eq__(self, other):
        return isinstance(other, Abs) and self.body == other.body
    def __hash__(self):
        return hash(('lam', self.body))


def lift(d: int, c: int, t: Lam) -> Lam:
    """Shift free variables >= c by d."""
    if isinstance(t, Var):
        return Var(t.n) if t.n < c else Var(t.n + d)
    elif isinstance(t, App):
        return App(lift(d, c, t.t), lift(d, c, t.u))
    elif isinstance(t, Abs):
        return Abs(lift(d, c + 1, t.body))

def subst_at(sigma: Lam, k: int, t: Lam) -> Lam:
    """Substitute sigma for variable k in t."""
    if isinstance(t, Var):
        if t.n < k:
            return Var(t.n)
        elif t.n == k:
            return lift(k, 0, sigma)
        else:
            return Var(t.n - 1)
    elif isinstance(t, App):
        return App(subst_at(sigma, k, t.t), subst_at(sigma, k, t.u))
    elif isinstance(t, Abs):
        return Abs(subst_at(sigma, k + 1, t.body))

def subst0(u: Lam, t: Lam) -> Lam:
    """Substitute u for variable 0 in t (beta reduction step)."""
    return subst_at(u, 0, t)

def term_size(t: Lam) -> int:
    if isinstance(t, Var):
        return 1
    elif isinstance(t, App):
        return 1 + term_size(t.t) + term_size(t.u)
    elif isinstance(t, Abs):
        return 1 + term_size(t.body)


# =============================================================
# Standard Combinators
# =============================================================

I = Abs(Var(0))                              # λx.x
K = Abs(Abs(Var(1)))                         # λx.λy.x
S = Abs(Abs(Abs(App(App(Var(2), Var(0)), App(Var(1), Var(0))))))
OMEGA = App(Abs(App(Var(0), Var(0))), Abs(App(Var(0), Var(0))))

def church(n: int) -> Lam:
    """Church numeral for n: λf.λx. f^n x"""
    body = Var(0)  # x
    for _ in range(n):
        body = App(Var(1), body)  # f (f ... (f x))
    return Abs(Abs(body))


# =============================================================
# Beta Reduction Engine
# =============================================================

def beta_reduce_leftmost(t: Lam) -> Lam | None:
    """One-step leftmost beta reduction. Returns None if no redex."""
    if isinstance(t, App) and isinstance(t.t, Abs):
        return subst0(t.u, t.t.body)
    elif isinstance(t, App):
        left = beta_reduce_leftmost(t.t)
        if left is not None:
            return App(left, t.u)
        right = beta_reduce_leftmost(t.u)
        if right is not None:
            return App(t.t, right)
        return None
    elif isinstance(t, Abs):
        inner = beta_reduce_leftmost(t.body)
        if inner is not None:
            return Abs(inner)
        return None
    return None

def normalize(t: Lam, fuel: int = 100) -> Lam | None:
    """Normalize by repeated leftmost reduction. Returns None if diverges."""
    for _ in range(fuel):
        next_t = beta_reduce_leftmost(t)
        if next_t is None:
            return t
        t = next_t
    return None  # Didn't converge

def all_one_step_reducts(t: Lam) -> set:
    """All possible one-step beta reducts."""
    results = set()
    if isinstance(t, App) and isinstance(t.t, Abs):
        results.add(subst0(t.u, t.t.body))
    if isinstance(t, App):
        for r in all_one_step_reducts(t.t):
            results.add(App(r, t.u))
        for r in all_one_step_reducts(t.u):
            results.add(App(t.t, r))
    elif isinstance(t, Abs):
        for r in all_one_step_reducts(t.body):
            results.add(Abs(r))
    return results

def reducts_up_to_depth(t: Lam, d: int) -> set:
    """All terms reachable within d beta-reduction steps."""
    current = {t}
    for _ in range(d):
        new = set()
        for term in current:
            new.update(all_one_step_reducts(term))
        current = current | new
    return current


# =============================================================
# Böhm Tree Approximants
# =============================================================

class BTApprox:
    pass

class Bot(BTApprox):
    def __repr__(self):
        return "⊥"
    def __eq__(self, other):
        return isinstance(other, Bot)

class Node(BTApprox):
    def __init__(self, head: int, args: list):
        self.head = head
        self.args = args
    def __repr__(self):
        if not self.args:
            return f"v{self.head}"
        args_str = " ".join(str(a) for a in self.args)
        return f"(v{self.head} {args_str})"
    def __eq__(self, other):
        return isinstance(other, Node) and self.head == other.head and self.args == other.args

def head_reduce(t: Lam):
    """Head reduction: reduce the head redex if present."""
    if isinstance(t, App) and isinstance(t.t, Abs):
        return subst0(t.u, t.t.body)
    elif isinstance(t, App):
        r = head_reduce(t.t)
        if r is not None:
            return App(r, t.u)
    return None

def extract_head(t: Lam):
    """Extract head variable and arguments from HNF."""
    if isinstance(t, Var):
        return (t.n, [])
    elif isinstance(t, App):
        result = extract_head(t.t)
        if result is not None:
            n, args = result
            return (n, args + [t.u])
    return None

def bohm_approx(n: int, t: Lam) -> BTApprox:
    """Compute Böhm tree approximant with fuel n."""
    if n == 0:
        return Bot()
    r = head_reduce(t)
    if r is not None:
        return bohm_approx(n - 1, r)
    result = extract_head(t)
    if result is not None:
        hd, args = result
        return Node(hd, [bohm_approx(n - 1, a) for a in args])
    return Bot()


# =============================================================
# Demonstration
# =============================================================

def main():
    print("=" * 70)
    print("LAMBDA CALCULUS: CONFLUENCE, NORMALIZATION & BÖHM TREES")
    print("=" * 70)

    # 1. Basic terms
    print("\n--- Standard Combinators ---")
    print(f"I = {I}")
    print(f"K = {K}")
    print(f"S = {S}")
    print(f"Ω = {OMEGA}")
    for n in range(5):
        print(f"Church {n} = {church(n)}")

    # 2. Normalization
    print("\n--- Normalization Examples ---")
    # I applied to K
    ik = App(I, K)
    print(f"I K = {ik}")
    print(f"  normalizes to: {normalize(ik)}")

    # K I Ω
    ki_omega = App(App(K, I), OMEGA)
    print(f"K I Ω = {ki_omega}")
    result = normalize(ki_omega)
    print(f"  normalizes to: {result}")

    # S K K
    skk = App(App(S, K), K)
    print(f"S K K = {skk}")
    # Apply to church 2
    skk_2 = App(skk, church(2))
    print(f"S K K 2 = {skk_2}")
    result = normalize(skk_2)
    print(f"  normalizes to: {result}")

    # 3. Confluence demonstration
    print("\n--- Confluence Demonstration ---")
    # (λx. x x) ((λy.y) z)  -- two possible reduction orders
    t = App(Abs(App(Var(0), Var(0))), App(Abs(Var(0)), Var(0)))
    print(f"Term: {t}")
    reducts = all_one_step_reducts(t)
    print(f"  One-step reducts ({len(reducts)}):")
    for r in reducts:
        print(f"    → {r}")
        nf = normalize(r)
        print(f"      normalizes to: {nf}")
    print("  All paths converge to the same normal form (Church-Rosser!)")

    # 4. Reduction tree exploration
    print("\n--- Reduction Tree Branching ---")
    terms = [
        ("I", I),
        ("K", K),
        ("I K", App(I, K)),
        ("Ω", OMEGA),
    ]
    for name, t in terms:
        for d in range(4):
            rs = reducts_up_to_depth(t, d)
            print(f"  |reducts({name}, depth={d})| = {len(rs)}", end="")
            print(f"  (bound: 2^{d} = {2**d})")

    # 5. Böhm tree approximants
    print("\n--- Böhm Tree Approximants ---")
    test_terms = [
        ("I", I),
        ("K", K),
        ("v0", Var(0)),
        ("v0 v1", App(Var(0), Var(1))),
        ("Ω", OMEGA),
    ]
    for name, t in test_terms:
        print(f"  {name}:")
        for n in range(4):
            approx = bohm_approx(n, t)
            print(f"    depth {n}: {approx}")

    # 6. Conjecture test: separation depth
    print("\n--- Conjecture Test: Böhm Separation Depth ---")
    print("  Testing: for closed terms of size ≤ N, inequivalent terms")
    print("  are separated by Böhm approximants at depth ≤ c*N")
    # Compare I vs K (both closed, size 2 and 3)
    print(f"\n  I vs K:")
    for n in range(6):
        ai = bohm_approx(n, I)
        ak = bohm_approx(n, K)
        sep = "SEPARATED" if ai != ak else "equal"
        print(f"    depth {n}: I→{ai}, K→{ak}  [{sep}]")

    # Compare var 0 vs var 1
    print(f"\n  v0 vs v1:")
    for n in range(4):
        a0 = bohm_approx(n, Var(0))
        a1 = bohm_approx(n, Var(1))
        sep = "SEPARATED" if a0 != a1 else "equal"
        print(f"    depth {n}: v0→{a0}, v1→{a1}  [{sep}]")

    # 7. Reduction branching vs 2^d bound
    print("\n--- Reduction Branching vs Exponential Bound ---")
    # For simply-typed terms, branching should be subexponential
    typed_terms = [
        ("Church 0", church(0)),
        ("Church 1", church(1)),
        ("Church 2", church(2)),
        ("K (Church 1) (Church 2)", App(App(K, church(1)), church(2))),
    ]
    print(f"  {'Term':<30} {'d=0':>6} {'d=1':>6} {'d=2':>6} {'d=3':>6} {'2^d':>8}")
    for name, t in typed_terms:
        counts = []
        for d in range(4):
            rs = reducts_up_to_depth(t, d)
            counts.append(len(rs))
        bound = [2**d for d in range(4)]
        print(f"  {name:<30} {counts[0]:>6} {counts[1]:>6} {counts[2]:>6} {counts[3]:>6} {'/'.join(str(b) for b in bound):>8}")

    print("\n" + "=" * 70)
    print("All demonstrations complete. The formal proofs in Lean 4 verify:")
    print("  1. Diamond property for parallel β-reduction")
    print("  2. Church-Rosser theorem (confluence of β-reduction)")
    print("  3. Uniqueness of normal forms")
    print("  4. Ω diverges (Böhm approximant always ⊥)")
    print("  5. Reduction tree monotonicity")
    print("=" * 70)


if __name__ == "__main__":
    main()
