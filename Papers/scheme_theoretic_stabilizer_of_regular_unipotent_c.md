# Computational Evidence — Stabilizer of a regular unipotent class under `Z(G')`

Target: for a regular unipotent `u` in a reductive `G` with universal cover
`π : G' → G`, the scheme-theoretic stabilizer `Stab_{Z(G')}(C_{u'})` equals
`ker π`.  Concrete model: `G' = SL₂`, `G = PGL₂`, `π : SL₂ → PGL₂`.

## 1. Small-case calculations (`SL₂`, regular unipotent `u = [[1,1],[0,1]]`)

Centralizer of `u` inside `2×2` matrices `M = [[a,b],[c,d]]`:

    M·u = [[a, a+b], [c, c+d]],   u·M = [[a+c, b+d], [c, d]].

Equating: `c = 0` and `a = d`.  So the centralizer is `{[[a,b],[0,a]]}`.
Adding `det = 1` gives `a² = 1`.  ✔ matches `centralizer_regular_unipotent`.

Center of `SL₂` = matrices commuting with both `u` and `l = [[1,0],[1,1]]`:
`b = 0`, `c = 0`, `a = d`, `a² = 1`, i.e. `{a·I : a² = 1} = μ₂`.
✔ matches `center_SL2_eq_mu2`.

## 2. `μ₂` point counts vs. characteristic

| char k | solutions of `a² = 1` | #points | scheme type      |
|--------|-----------------------|---------|------------------|
| 0, 3, 5, 7, … (≠2) | `a = 1, a = -1`   | 2       | étale (reduced)  |
| 2      | `a = 1` only (`a²-1 = (a-1)²`) | 1 | infinitesimal (non-reduced) |

✔ matches `mu2_char_ne_two_etale` / `mu2_char_two_infinitesimal`.

## 3. Generalization to `μ_p` inside `SL_p` (char `p`)

Frobenius: `(x-1)^p = x^p - 1` in char `p`.  Thus `x^p = 1 ⇔ (x-1)^p = 0 ⇔ x = 1`.

| prime p | field char | solutions of `x^p = 1` | #points |
|---------|-----------|------------------------|---------|
| 2 | 2 | `{1}` | 1 |
| 3 | 3 | `{1}` | 1 |
| 5 | 5 | `{1}` | 1 |
| 3 | 0 (ℂ) | 3 cube roots of unity | 3 |

`det(a·I_p) = a^p`, so `a·I ∈ SL_p ⇔ a^p = 1`.  In char `p` the only `k`-point
is the identity, yet the equation `a^p = 1` is non-reduced (length `p`).
✔ matches `det_scalar`, `ker_pi_SLp_trivial_points`.

## 4. Counterexample hunt

Claim tested: "the stabilizer of the regular unipotent class inside `Z(SL₂)` is
strictly smaller than `Z(SL₂)`."  FALSE for `SL₂`: every central element is
scalar, hence commutes with `u`, so the (point) stabilizer is all of `Z(SL₂)`,
which here equals `ker π`.  No counterexample to the target identity
`Stab = ker π` was found; the subtlety is entirely in the non-reduced structure,
not the point set.

## 5. OEIS

The point counts `1, 1, 1, …` (char `p`) and `2, 2, 2, …` (char `≠2`) are
constant sequences; no informative OEIS entry.  The étale point count of `μ_n`
in characteristic coprime to `n` is `n` itself (A000027).
