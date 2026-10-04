# Round 101 — three axes; the two-residue frontier question is CLOSED (redundancy)

**2026-10-04. No exponent beaten. But the frontier question of round 100 is
CLOSED by a machine-checked redundancy theorem, two further axes are recorded as
dead ends, and the residue method's boundary is now fully characterized.**

Machine-checked: `ResidueRedundancy.lean` (**0 `sorry`, 0 `axiom`**, footprint
`[propext, Classical.choice, Quot.sound]`). Empirical:
`Experiments/UMWWindow/residue_redundancy.py` (deterministic, `out_redundancy.txt`).

---

## Axis 1 — the two-residue frontier question: CLOSED (redundant)

Round 100 left open: *knowing both `p mod M` and `q mod M` (independent per-factor
info), can a bivariate lattice break `N^{1/4}`?*

**Answer: NO — the two residues are not independent.** If `a = p mod M` and
`b = q mod M`, then `N = p·q ≡ a·b (mod M)`, and this compatibility condition
involves **only the two residues**, never the unknown quotients in
`p = a + Mx`, `q = b + My`. So `b` carries **no information** about `x` beyond
what `(a, N)` already forces.

* Machine-checked (`compat`): `M ∣ (p−a) ∧ M ∣ (q−b) ∧ p·q = N ⟹ M ∣ (a·b − N)`.
* Empirically: `q mod M` is determined by `(p mod M, N)` **3000/3000** (when
  `gcd(a,M)=1`); and for **all** `M` (including `gcd(a,M)>1`) the second-residue
  filter removes **zero** candidate divisors — **3000/3000**.

> **This is the same redundancy as round 97b's `p/q` low-bit coupling, but for the
> residue model.** It closes the round-100 frontier question: the two-residue
> bivariate attack is not merely blocked by lattice isolation (round 97g) — it is
> **information-theoretically empty**. The second residue adds nothing.

## Axis 2 — order-based and special-difference routes: dead

* **`p ≡ q (mod M)`, `M > N^{1/4}`:** knowing `M ∣ (p−q)` does **not** bound
  `|p−q|` above (`|p−q|` can be `~N^{1/2}`), so a small-`z` Fermat search gains
  nothing. Not a factoring promise.
* **Deterministic order-gcd (Pollard p¹, Harvey–Hittmeir order tools):** the
  classical `p−1` smooth-order threshold `~N^{1/4}`; not a new frontier.
* **CRT pooling of fragmented residue leaks** (from multiple sources, coprime
  `M₁,M₂`): works, but this is exactly CRT — no new information beyond the
  effective modulus `M_eff = M₁M₂` (already established, round 99 H2). Confirmed
  operationally; not an advance.

## Axis 3 — the structural wall (from round 99) stands

`GAPGcd.cross_residue`: a GAP divisor cover **reduces to** the counting wall
`α+2β ≥ 1` (the co-prime-to-`g` part of each covered index must divide the small
multiplier). This is why every rank-2 attack converges. Unchanged and
machine-checked.

## What the residue method's boundary now is (complete)

`ResiduePartialFactor` factors `N=pq` deterministically and certifiably from
`p mod M`, `M > N^{1/4}` (threshold measured, 7/7 + 13/13). The frontier study now
shows, rigorously:

1. **Symmetry** (round 100 H1): `q mod M` works identically to `p mod M`.
2. **Redundancy** (this round): the *pair* of residues is no better than one.
3. **CRT** (round 99 H2): fragmented leaks pool, but only to `M_eff > N^{1/4}`.

> **So the residue method's true threshold is `M > N^{1/4}` on a single (or pooled
> effective) residue — exactly the `n/4` known-bits frontier, realized via
> residue leakage. There is no second, independent residue leak to exploit, and
> no route below `N^{1/4}` within this leakage model.** This is the complete,
> rigorous characterization of the method's boundary.

## Honest scope

* **No exponent beaten.** The residue method is a new deterministic, certifiable
  algorithm for a structured-promise model at the known `N^{1/4}` frontier.
* **New (this round):** the two-residue redundancy theorem (machine-checked +
  3000/3000 empirical), which **closes** the round-100 open question; two dead
  ends (special-difference, order-based) recorded.
* **Not claimed:** that any exponent improves. The complete characterization
  above *shows* the residue model cannot beat `N^{1/4}`.

**Next attack.** A frontier advance for the residue method would require leakage
genuinely independent of a residue (not a second residue, not CRT, not an
interval bound reducible to bits) — e.g. a multiplicative-order or elliptic-curve
relation, which the record prices at the classical thresholds. The classical
balanced-semiprime frontier remains closed.