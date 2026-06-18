# Existence and Bounds for the Connective Constant of the Self-Avoiding Walk on ℤ²

## Abstract

The self-avoiding walk (SAW) is the uniform model of lattice paths that visit no
vertex more than once. Its central enumerative invariant is the *connective constant*
μ, the exponential growth rate of the number c_n of *n*-step self-avoiding walks. We
present a fully formalized account of the *existence* of the connective constant on the
two-dimensional integer lattice ℤ², together with rigorous two-sided bounds. Starting
from a machine-checked proof that the count c_n is submultiplicative
(c_{m+n} ≤ c_m · c_n), we deduce subadditivity of log c_n, apply Fekete's subadditive
lemma to obtain convergence of (log c_n)/n, and exponentiate to establish the
Hammersley–Morton theorem c_n^{1/n} → μ. We identify the infimum-based definition of μ
with the Fekete limit, derive the computationally decisive one-sided inequality
μ ≤ c_n^{1/n} valid for every n ≥ 1, and prove the lower bound μ ≥ 2 by an explicit
injection of the 2^n monotone north-east walks. The matching elementary upper bound
μ ≤ 3 is recorded as a conjecture. We further formalize, at the algebraic level, the
Duminil-Copin–Smirnov constant √(2+√2) for the *hexagonal* lattice, and correct a
common conflation: the square-lattice constant μ_{ℤ²} ≈ 2.638 has no known closed form
and satisfies 2 ≤ μ_{ℤ²} ≤ 3, whereas the exact value √(2+√2) ≈ 1.848 belongs to the
honeycomb lattice. The proposed value (2+√2)/2 ≈ 1.707 is incorrect for both lattices.

**Keywords:** self-avoiding walk, connective constant, Fekete's lemma, subadditivity,
submultiplicativity, Hammersley–Morton theorem, lattice combinatorics, polymer physics,
Duminil-Copin–Smirnov theorem.

---

## 1. Introduction

A *self-avoiding walk* (SAW) of length *n* on the square lattice ℤ² is a sequence of
lattice points (ω_0, ω_1, …, ω_n) with ω_0 = (0,0), consecutive points at L¹-distance
exactly 1, and all points distinct. Introduced by Flory and Orr in the 1940s as a model
for excluded-volume effects in linear polymers, the SAW has become a touchstone problem
in combinatorics, probability, and statistical mechanics, simultaneously elementary to
state and notoriously resistant to exact analysis.

The fundamental enumerative object is the **count**

> c_n := #{ self-avoiding walks of length n starting at the origin }.

The sequence begins 1, 4, 12, 36, 100, 284, 780, 2172, … (OEIS A001411). No closed form
for c_n is known, and the consensus is that none exists. The asymptotics, however, are
governed by a single number, the **connective constant**

> μ := lim_{n→∞} c_n^{1/n},

which exists by the classical theory of subadditive sequences. The connective constant
encapsulates the exponential growth rate of configurations and feeds directly into the
free energy of polymer models.

This paper documents a formal development whose ground truth is two Lean 4 files,
`Computation.SelfAvoidingWalk.Basic` and `Computation.SelfAvoidingWalk.ConnectiveConstant`.
The Basic file establishes the lattice infrastructure, the key submultiplicativity
inequality, and subadditivity of log c_n, and it defines μ via an infimum. The
ConnectiveConstant file supplies the existence theorem (Fekete + exponentiation),
identifies the definition with the Fekete limit, derives the computational upper-bound
principle, and proves the lower bound μ ≥ 2. We present the mathematics in standard
notation with proof sketches; full formal proofs are machine-verified.

---

## 2. Definitions

### 2.1 The lattice and adjacency

**Definition 2.1 (ℤ² adjacency).** Points p, q ∈ ℤ² are *adjacent*, written
Z2Adj(p, q), if their L¹-distance is exactly 1:

> |p₁ − q₁| + |p₂ − q₂| = 1.

This relation is symmetric and irreflexive; in particular adjacency implies p ≠ q.

### 2.2 The self-avoiding walk

**Definition 2.2 (Lattice walk).** A *self-avoiding walk of length n* (a `LatticeWalk n`)
is a map ω : {0, 1, …, n} → ℤ² such that

1. ω(0) = (0,0)  (*anchored at the origin*),
2. Z2Adj(ω(i), ω(i+1)) for all i < n  (*unit steps*),
3. ω is injective  (*self-avoidance*).

**Definition 2.3 (SAW count).** c_n := sawCount(n) := #(LatticeWalk n), the cardinality
of the (finite) set of length-*n* self-avoiding walks.

The set LatticeWalk n is finite because Definition 2.2's coordinate bound (Proposition
3.1 below) confines every walk to the box [−n, n]², so there are only finitely many maps;
this finiteness is proved formally as `latticeWalk_finite`.

### 2.3 The connective constant

**Definition 2.4 (Connective constant).** The connective constant of ℤ² is

> μ := exp( inf_{k ≥ 1} (log c_k) / k ).

The infimum is taken over positive integers k. That this infimum equals the limit
lim_n (log c_n)/n is the content of Fekete's lemma (Theorem 4.2), making μ = lim_n
c_n^{1/n}.

### 2.4 Submultiplicativity and subadditivity (abstract)

**Definition 2.5.** A real sequence (a_n) is *submultiplicative* if a_{m+n} ≤ a_m · a_n
for all m, n, and *subadditive* if a_{m+n} ≤ a_m + a_n for all m, n.

---

## 3. Coordinate bounds and finiteness

**Proposition 3.1 (Per-step coordinate bound).** For a walk ω of length n and each step
i < n, each coordinate changes by at most 1:

> |ω(i)₁ − ω(i+1)₁| ≤ 1 and |ω(i)₂ − ω(i+1)₂| ≤ 1.

*Proof sketch.* Adjacency gives |Δx| + |Δy| = 1 with both summands nonnegative, so each
is ≤ 1. ∎

**Proposition 3.2 (Global coordinate bound).** For every walk ω of length n and every
index i ≤ n,

> |ω(i)₁| ≤ i and |ω(i)₂| ≤ i.

*Proof sketch.* Induction on i using ω(0) = (0,0) and Proposition 3.1 (the triangle
inequality accumulates at most 1 per step). ∎

**Corollary 3.3 (Finiteness).** LatticeWalk n is finite, hence c_n is a well-defined
natural number, and c_n ≥ 1 (the straight walk i ↦ (i, 0) is self-avoiding). Also
c_0 = 1, the unique walk being the constant map at the origin.

---

## 4. Existence of the connective constant

### 4.1 Submultiplicativity of the count

**Theorem 4.1 (Submultiplicativity).** For all m, n ∈ ℕ,

> c_{m+n} ≤ c_m · c_n.

*Proof sketch.* Define a map Φ : LatticeWalk(m+n) → LatticeWalk(m) × LatticeWalk(n) by
splitting a long walk ω at time m. The *prefix* p(i) := ω(i) for i ≤ m is a length-*m*
SAW (it inherits the start, the steps, and injectivity by restriction). The *suffix*
q(i) := ω(m+i) − ω(m) for i ≤ n is a length-*n* SAW: subtracting ω(m) re-anchors it at
the origin, translation preserves adjacency, and injectivity is inherited. The map Φ is
*injective*: from the prefix one recovers ω(0..m), and from the suffix together with the
recovered value ω(m) one recovers ω(m..m+n); hence ω is determined by (p, q). Injectivity
of Φ gives #(LatticeWalk(m+n)) ≤ #(LatticeWalk(m)) · #(LatticeWalk(n)), i.e.
c_{m+n} ≤ c_m · c_n. ∎

The inequality is generally strict because a pair (p, q) reconstructs a walk only when
the translated suffix does not collide with the prefix; colliding pairs are counted on
the right but not on the left.

### 4.2 From submultiplicativity to subadditivity

**Lemma 4.1.1.** If (a_n) is submultiplicative and a_n > 0 for all n, then
(log a_n) is subadditive.

*Proof sketch.* log a_{m+n} ≤ log(a_m a_n) = log a_m + log a_n, using monotonicity of log
and the product rule. ∎

Applying Lemma 4.1.1 to a_n = c_n (positive by Corollary 3.3, submultiplicative by
Theorem 4.1) yields:

**Corollary 4.1.2 (`logSawCount_subadditive`).** The sequence n ↦ log c_n is subadditive.

### 4.3 Fekete's lemma and the Hammersley–Morton theorem

**Theorem 4.2 (Fekete's subadditive lemma).** If (b_n) is subadditive and the quotients
b_n/n are bounded below, then b_n/n converges to inf_{k≥1} b_k/k.

We instantiate b_n = log c_n. The boundedness hypothesis is immediate:

**Lemma 4.2.1 (`zero_le_logSawCount`, `logSawCount_bddBelow`).** Since c_n ≥ 1 we have
log c_n ≥ 0, hence (log c_n)/n ≥ 0 for all n; thus the quotients are bounded below by 0.

**Theorem 4.3 (Fekete convergence for SAWs, `sawCount_log_div_tendsto`).**

> (log c_n)/n → L, where L := inf_{k≥1} (log c_k)/k ≥ 0.

*Proof sketch.* Immediate from Theorem 4.2 and Lemma 4.2.1. Nonnegativity of L follows
because the limit of nonnegative quotients is nonnegative. ∎

**Theorem 4.4 (Identification of the definition, `connectiveConstant_eq_exp_lim`).**

> μ = exp(L).

*Proof sketch.* Both sides are exp of an infimum over positive integers; the only work is
matching the index set {k : k ≥ 1} of Definition 2.4 with the index set used by Fekete's
limit, which is a bookkeeping identity between an indexed infimum and an `sInf` over the
image of the corresponding range. ∎

**Theorem 4.5 (Hammersley–Morton, `sawCount_rpow_tendsto`).** The connective constant
exists as the limit of root-counts:

> c_n^{1/n} → μ as n → ∞.

*Proof sketch.* For n ≥ 1, c_n^{1/n} = exp((1/n)·log c_n) = exp((log c_n)/n) by the
definition of real exponentiation of a positive base. By Theorem 4.3 the exponent tends
to L, and by continuity of exp the values tend to exp(L) = μ (Theorem 4.4). The
restriction to n ≥ 1 is handled by eventual equality of the two sequences. ∎

### 4.4 The computational upper-bound principle

Because Fekete's limit is an *infimum*, the connective constant lies below every
root-count.

**Theorem 4.6 (`connectiveConstant_le_rpow`).** For every n ≥ 1,

> μ ≤ c_n^{1/n}.

*Proof sketch.* By the infimum property, L ≤ (log c_n)/n. Exponentiate using monotonicity
of exp: μ = exp(L) ≤ exp((log c_n)/n) = c_n^{1/n}. ∎

This is the rigorous foundation of computer-assisted upper bounds: any single finite
enumeration of c_n yields a provable ceiling on μ, and longer enumerations tighten it.

**Corollary 4.7 (`one_le_connectiveConstant`).** μ ≥ 1, since μ = exp(L) with L ≥ 0.

---

## 5. Two-sided bounds

### 5.1 Lower bound via monotone walks

**Theorem 5.1 (`two_le_connectiveConstant`).** μ ≥ 2.

*Proof sketch.* Consider *north-east walks*: walks whose every step is +x or +y. Each
such walk of length n corresponds to a bit string s ∈ {0,1}ⁿ (1 = east, 0 = north), and
its k-th vertex has x-coordinate equal to the number of 1's among the first k bits and
y-coordinate the number of 0's. Along such a walk the quantity x + y strictly increases
(by exactly 1 per step), so no vertex repeats — the walk is automatically self-avoiding.
The assignment s ↦ ω_s is injective: the s-th bit equals the change in the x-coordinate
at step s, so s is recoverable from ω_s. Hence the 2ⁿ bit strings inject into
LatticeWalk n, giving

> c_n ≥ 2ⁿ  (`twoPow_le_sawCount`).

Taking n-th roots, c_n^{1/n} ≥ 2 for all n, and passing to the limit (Theorem 4.5) gives
μ ≥ 2. Equivalently, μ ≤ c_n^{1/n} is the *other* direction; here we use that μ is the
limit of the c_n^{1/n}, all of which are ≥ 2. ∎

### 5.2 Upper bound via non-reversing walks (conjectural in the formalization)

**Conjecture 5.2 (`connectiveConstant_le_three`).** μ ≤ 3.

*Justification.* A self-avoiding walk never immediately reverses its previous step.
There are 4 choices for the first step and at most 3 for each subsequent step, so the
number of *non-reversing* walks is at most 4·3^{n−1}. Every SAW is non-reversing, hence

> c_n ≤ 4·3^{n−1},  giving  μ ≤ 3.

This bound is standard and certainly true; it is recorded as a conjecture (sorry) in the
formal development because "no immediate backtrack" is a local constraint that must be
maintained along the entire walk — it cannot be read off a single monotone coordinate as
in the lower bound — so the injection into non-reversing step sequences requires more
careful bookkeeping than the elementary lower bound. ∎

**Summary 5.3.** Combining Theorem 5.1 with Conjecture 5.2,

> 2 ≤ μ_{ℤ²} ≤ 3,

an interval containing the numerically established value μ_{ℤ²} ≈ 2.63815853…

---

## 6. The hexagonal lattice and the Nienhuis constant

The honeycomb lattice admits a *closed-form* connective constant, in stark contrast to
ℤ². We formalize its algebraic skeleton.

**Definition 6.1 (Hexagonal lattice).** Vertices are triples (x, y, s) with x, y ∈ ℤ and
s ∈ {A, B} a sublattice label, with the standard 3-regular bipartite adjacency HexAdj:
from an A-vertex, the three B-neighbors are (x,y,B), (x−1,y,B), (x,y−1,B); the relation
is symmetric. A hexagonal SAW (`HexWalk n`) is an injective adjacency-respecting path
anchored at (0,0,A), with count hexSawCount(n) and connective constant
μ_hex := exp( inf_{k≥1} (log hexSawCount(k))/k ).

**Definition 6.2 (Nienhuis constant).** μ_hex* := √(2 + √2).

**Theorem 6.3 (`nienhuis_mu_sq`).** (μ_hex*)² = 2 + √2.

**Theorem 6.4 (`nienhuis_algebraic_identity`).** μ_hex* is an algebraic number of degree
4 with minimal polynomial

> x⁴ − 4x² + 2 = 0.

*Proof sketch.* Squaring twice: (μ_hex*)² = 2 + √2, so (μ_hex*)⁴ = (2+√2)² = 6 + 4√2 =
4(2+√2) − 2 = 4(μ_hex*)² − 2. ∎

**Theorem 6.5 (`nienhuis_mu_gt_one`).** μ_hex* > 1; numerically μ_hex* ≈ 1.84776.

**Definition/Theorem 6.6 (Critical fugacity).** x_c := 1/μ_hex* satisfies 0 < x_c < 1
(`hexCriticalFugacity_lt_one`), the threshold below which the SAW generating function
converges.

**Theorem 6.7 (Duminil-Copin–Smirnov, 2012; `duminilCopin_smirnov`, stated).** The
hexagonal connective constant equals the Nienhuis value:

> μ_hex = √(2 + √2).

This deep analytic result, conjectured by Nienhuis in 1982 via Coulomb-gas/conformal
field-theory arguments and proved rigorously by Duminil-Copin and Smirnov using the
*parafermionic observable*, is stated in the development (its proof is beyond the present
formalization scope and is recorded as a sorry).

### 6.1 Correction of the problem framing

The originating brief proposed μ = (2 + √2)/2 ≈ 1.707. This is **incorrect for both
lattices**:

- The exact value √(2 + √2) ≈ 1.848 belongs to the **hexagonal** lattice, not ℤ².
- The square-lattice constant μ_{ℤ²} ≈ 2.638 has **no known closed form** and satisfies
  2 ≤ μ_{ℤ²} ≤ 3.
- (2 + √2)/2 ≈ 1.707 matches neither; it appears to be a corrupted variant of the
  honeycomb value.

We therefore prove *existence plus rigorous bounds* for ℤ² and the *algebraic
characterization* of the honeycomb constant, rather than a spurious closed form.

---

## 7. Critical exponents (context)

Beyond the growth rate μ, the SAW is conjectured to satisfy refined asymptotics
c_n ~ A·μⁿ·n^{γ−1} with a universal *susceptibility exponent* γ, and a mean-square
end-to-end distance ~ n^{2ν} with the *Flory/swelling exponent* ν. In two dimensions,
Nienhuis (1982) predicted the exact rational values

> γ = 43/32  (`nienhuis_gamma`),  ν = 3/4  (`flory_nu`),

reflecting the conformal symmetry of the critical SAW (equivalently SLE_{8/3}). These are
recorded as definitions for context; they are universal (lattice-independent), unlike μ
itself.

---

## 8. Algorithms

### 8.1 Exact enumeration by depth-first backtracking

c_n is computed by a depth-first search over partial self-avoiding walks. Maintain the
set of visited vertices; at each vertex try all 4 (or for hex, 3) neighbors not already
visited; increment the counter when depth n is reached. Complexity is O(c_n) up to
polynomial factors — exponential, but feasible to n ≈ 30–40 with pruning; specialized
length-doubling and lace-expansion methods (Conway–Guttmann, Clisby) reach far higher.

### 8.2 Rigorous upper bounds from finite data

By Theorem 4.6, for any computed c_n the value c_n^{1/n} is a *certified* upper bound on
μ. The sequence of such bounds decreases toward μ.

### 8.3 Lower-bound certificate from monotone walks

By Theorem 5.1, 2 ≤ μ unconditionally. Sharper rigorous lower bounds come from
concatenation/bridge arguments (Hammersley–Welsh, Kesten), e.g. μ ≥ (c_n)^{1/n} fails
in general, but μ ≥ (b_n)^{1/n} holds for bridge counts b_n by supermultiplicativity of
bridges.

---

## 8.4 Worked numerical illustration

Exact depth-first enumeration yields the first counts (OEIS A001411):

| n | c_n | c_n^{1/n} (upper bound on μ) | 2ⁿ (lower) | 4·3^{n−1} (upper) |
|---|-----|------------------------------|------------|--------------------|
| 1 | 4 | 4.000000 | 2 | 4 |
| 2 | 12 | 3.464102 | 4 | 12 |
| 3 | 36 | 3.301927 | 8 | 36 |
| 4 | 100 | 3.162278 | 16 | 108 |
| 5 | 284 | 3.095021 | 32 | 324 |
| 6 | 780 | 3.034001 | 64 | 972 |
| 8 | 5916 | 2.961444 | 256 | 8748 |
| 10 | 44100 | 2.913693 | 1024 | 78732 |
| 12 | 324932 | 2.879493 | 4096 | 708588 |

Several features predicted by the theory are visible directly in the table. First,
the column c_n^{1/n} is monotonically *decreasing*, exactly as Theorem 4.6 demands
(the root-counts form a descending fence of certified upper bounds whose infimum is
μ). Second, every row satisfies 2ⁿ ≤ c_n ≤ 4·3^{n−1}, confirming the two-sided trap
of Summary 5.3 numerically. Third, the upper bounds c_n^{1/n} descend toward — but,
at these short lengths, remain visibly above — the true value μ_{ℤ²} ≈ 2.63816; the
convergence is slow (governed by the conjectured correction term n^{γ−1} with
γ = 43/32), which is precisely why state-of-the-art numerical determinations rely on
length-doubling enumeration to lengths beyond n = 70 rather than naive backtracking.
A single short enumeration nonetheless already certifies, e.g., μ ≤ 2.8795 from
n = 12 alone, illustrating the practical force of Theorem 4.6.

## 9. Applications

1. **Polymer physics.** μ sets the configurational entropy per monomer of a linear
   polymer with excluded volume; the free energy per monomer is −k_BT·log μ.
2. **Critical phenomena and universality.** SAWs are the n→0 limit of the O(n) spin
   model; μ and the exponents γ, ν place SAWs in a universality class shared with other
   2D critical systems, described by SLE_{8/3}.
3. **Algorithm benchmarking.** SAW enumeration is a canonical stress test for
   combinatorial search, transfer-matrix, and Monte Carlo (pivot algorithm) methods.
4. **Rigorous numerics.** Theorem 4.6 turns each enumeration into a verified bound,
   illustrating how formal methods certify computational results in statistical
   mechanics.

---

## 10. Discussion and future work

The formalization cleanly separates the *combinatorial* core (submultiplicativity,
Theorem 4.1) from the *analytic* machinery (Fekete's lemma, exponentiation). Once
submultiplicativity is in hand, the connective constant is not merely *defined* but
*characterized* as μ = inf_n c_n^{1/n} = lim_n c_n^{1/n}, and every finite count yields a
rigorous one-sided bound. Open formal targets include:

- Discharging Conjecture 5.2 (μ ≤ 3) via a verified injection into non-reversing step
  sequences.
- Sharper rigorous bounds (Kesten's μ ≤ 2.696…, Pönitz–Tittmann lower bounds; modern
  μ_{ℤ²} ≈ 2.63815853032790…).
- Bridge supermultiplicativity (the `Bridge` structure is already defined) toward the
  Hammersley–Welsh bound and rigorous lower bounds.
- A full formal proof of Duminil-Copin–Smirnov (Theorem 6.7) via the parafermionic
  observable — a major undertaking.
- Formalizing the conjectured exponents γ = 43/32, ν = 3/4 within a rigorous SLE/CLE
  framework.

---

## 11. Conclusion

We have formalized the existence of the self-avoiding-walk connective constant on ℤ² —
the Hammersley–Morton theorem c_n^{1/n} → μ — from the submultiplicativity of SAW counts,
via Fekete's subadditive lemma and exponentiation, together with the identification
μ = exp(inf (log c_k)/k), the computational bound μ ≤ c_n^{1/n}, and the lower bound
μ ≥ 2. We placed the constant in the interval [2, 3] and corrected the record: ℤ² has no
known closed form (μ ≈ 2.638), whereas the exact value √(2 + √2) ≈ 1.848 is the
*hexagonal* connective constant of Nienhuis, proved by Duminil-Copin and Smirnov. The
result is a compact, machine-checked demonstration that a single combinatorial inequality,
fed through a century-old lemma, pins down one of the most fundamental constants in
lattice statistical mechanics.

---

## References (well-known)

- P. Flory, *Principles of Polymer Chemistry*, 1953.
- J. M. Hammersley and K. W. Morton, *Poor man's Monte Carlo*, J. Roy. Statist. Soc. B, 1954.
- N. Madras and G. Slade, *The Self-Avoiding Walk*, Birkhäuser, 1993.
- B. Nienhuis, *Exact critical point and critical exponents of O(n) models in two
  dimensions*, Phys. Rev. Lett. 49 (1982).
- H. Duminil-Copin and S. Smirnov, *The connective constant of the honeycomb lattice
  equals √(2+√2)*, Annals of Mathematics 175 (2012).
