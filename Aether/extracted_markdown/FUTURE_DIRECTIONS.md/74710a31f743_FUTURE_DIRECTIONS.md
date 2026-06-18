# Future Directions — The Hodge Conjecture for Neural Networks

Derived from the cycle that produced `HodgeNumberBound.lean`,
`ActivationRegions.lean`, and `HodgeReLUBridge.lean`. Each conjecture below is
bold, falsifiable, and grows out of a concrete finding (or failure) of this
cycle.

---

## Conjecture 1 — The Lefschetz grade space of a width-`w` layer

**Statement.** For a single ReLU hidden layer of width `w`, there is a
`LefschetzOperator` (in the sense of `Geometry.StandardConjectures`) on the
graded space `⨁_{k=0}^{w} ℝ^{(w choose k)}` (grade `k` = "exactly `k` active
neurons"), the down-shift `L`, such that `dim ker L + dim range L = 2^w` and the
binomial multiplicities `(w choose k)` are exactly the dimensions of the graded
pieces (so `∑_k (w choose k) = 2^w`, already proved as `regionCap_le_pow`'s
equality case via `Nat.sum_range_choose`).

**The key insight is** that the "number of active neurons" is a genuine
cohomological grading, and the hyperplane class moves you up one grade — so the
already-proven combinatorial identity `∑ (w choose k) = 2^w` *is* the total
dimension in a Lefschetz rank–nullity law, upgrading the modest `ℝ × ℝ` curve
model `lefschetzCurve` of this cycle to arbitrary width.

**Why now?** This cycle proved the curve case (`lefschetzCurve_rank_nullity`)
and the combinatorial total (`hodgeBound_total`) *separately*; the only missing
piece is the explicit nilpotent down-shift on `Fin (w+1) → ℝ`, which Lean's
linear-algebra library now supports directly.

---

## Conjecture 2 — Zaslavsky realizability is sharp for generic ReLU layers

**Statement.** For a ReLU layer of width `m` acting on `ℝ^d` whose weight rows
are in general position, the number of *non-empty* activation regions
(`actRegion A bh s ≠ ∅`) equals `regionCap d m = ∑_{j≤d} (m choose j)` exactly,
not merely `≤ 2^m`.

**The key insight is** that `regionCap_succ` (proved this cycle) is *exactly*
Zaslavsky's recursion `r(d+1,m+1) = r(d+1,m) + r(d,m)`, so the only gap between
the unconditional bound `regionCap d m ≤ 2^m` and equality is a general-position
hypothesis that forces every new hyperplane to meet the existing arrangement
transversally.

**Why now?** The recursion is already a theorem; what remains is a geometric
non-degeneracy lemma (each added hyperplane gains exactly `regionCap (d-1) m`
cells), which Mathlib's affine-independence API makes tractable.

---

## Conjecture 3 — Inner widths contribute only polynomially to total cohomology

**Statement.** For a deep ReLU network with widths `(n, w₁, …, w_L, 1)`, the
total Hodge budget `∑_{p,q} h^{p,q}(V(f))` is `Θ(2^{w₁} · 2^{w_L} · ∏_{i} wᵢ)`:
exponential in the *outer* hidden widths and only *polynomial/linear* in the
inner ones.

**The key insight is** that `hodgeBound_total` already shows the *upper bound*
collapses to `2^{w₁}·2^{w_L}·∏ middle`; the conjecture is that this is also a
lower bound up to constants — depth and inner width buy you region count, but the
cohomological "shape budget" is dominated by the boundary layers.

**Why now?** With the closed-form total in hand (`hodgeBound_total`), the
question becomes a matching construction: exhibit networks whose decision
surfaces realize `Ω` of the bound, a concrete combinatorial search rather than an
abstract existence proof.

---

## Conjecture 4 — Every PL homology class is a ℤ-sum of region hyperplane sections

**Statement.** For any ReLU network `f : ℝ^n → ℝ`, every class in
`H_{n-2}(V(f); ℤ)` is an integer linear combination of the fundamental classes
of the hyperplane-section pieces `{affEval gₛ = 0} ∩ actRegion s` produced by
`decisionBoundary_inter_region`.

**The key insight is** that `regions_cover` (proved this cycle) already
exhibits `V(f)` as a *finite union* of such hyperplane sections, so the
piecewise-linear Hodge conjecture reduces to a Mayer–Vietoris bookkeeping over
the (finitely many) activation regions — no transcendental input is needed,
unlike the classical Hodge conjecture.

**Why now?** The decomposition into algebraic pieces is now a formal theorem;
the remaining step is a simplicial/cellular chain argument, for which Mathlib's
developing algebraic-topology library is the natural home.

---

## Conjecture 5 — A Hard-Lefschetz obstruction detects un-realizable architectures

**Statement.** There exist target homology profiles `{b_k}` such that *no* ReLU
network of widths `(n, w₁, …, w_L, 1)` has a decision surface with those Betti
numbers, and the obstruction is exactly a failure of the Hard-Lefschetz
inequality `b_{k} ≤ b_{k+2}` for `k < (dim - 1)/2` applied to the Lefschetz
operator of Conjecture 1.

**The key insight is** that the same `LefschetzOperator` skeleton from
`Geometry.StandardConjectures` that this cycle used to decompose a single section
(`reluNet_hodge_bridge`) imposes *unimodality* constraints on the whole Betti
vector — so architecture search has a previously-unnoticed algebraic obstruction.

**Why now?** This cycle established the first concrete handshake between a ReLU
decision surface and a Lefschetz operator; turning that handshake into an
inequality on Betti numbers is the natural escalation, and `hodge_index_*` in
`Geometry.StandardConjectures` already provides the signature machinery.
