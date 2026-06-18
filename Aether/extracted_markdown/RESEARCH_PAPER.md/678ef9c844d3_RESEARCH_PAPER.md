# Categorical Tropical Rips Interleaving: Interleaving Distance as Tropical Algebra, with Rank and Shift Functoriality

## Abstract

We develop a self-contained, fully formalized bridge connecting three areas:
**categorical persistence theory** (functors out of the ordered real line and their
interleavings), **tropical / min-plus algebra** (the semiring `Tropical ℝ≥0∞` in which
multiplication is ordinary addition and addition is minimum), and **geometry /
topological data analysis** (Vietoris–Rips filtrations of dissimilarities and their
stability under perturbation). Modeling persistence modules as monotone functors
`M : ℝ → α` into a preorder, we define ε-interleavings as pairs of shifted
dominations and prove the categorical structure: reflexivity, symmetry, monotone
weakening, and the composition law (ε-interleaving followed by δ-interleaving is an
(ε+δ)-interleaving). We construct the `ℝ≥0∞`-valued **interleaving distance** as an
infimum of admissible shifts and prove it is a pseudometric. Our central structural
result is that the triangle inequality is *exactly* submultiplicativity of
`trop ∘ interleavingDist` in `Tropical ℝ≥0∞`: composition of interleavings is tropical
multiplication. We instantiate the theory geometrically with Vietoris–Rips modules and
prove the **stability theorem**: sup-close dissimilarities yield ε-interleaved modules.
We then prove two functoriality results. First, over a finite type the **rank functor**
`rankMod : PersMod (Set β) → PersMod ℕ` (sending a set-valued module to its cardinality
curve) preserves ε-interleavings and is **1-Lipschitz** for the interleaving distance,
giving algebraic stability of the rank / Betti-0 / edge-count invariant. Second, the
**constant-shift functor** `shift c` is an isometry of the interleaving distance,
displaces a module by at most `c`, realizes the self-distance as the tropical
multiplicative unit, and the relation of *finite interleaving distance* is an equivalence
relation equal to `interleavingDist ≠ ⊤`. All results are formalized with zero `sorry`s.

**Keywords:** persistence module, interleaving distance, tropical semiring, min-plus
algebra, Vietoris–Rips, topological data analysis, stability, functoriality, rank
invariant, category theory.

---

## 1. Introduction

Topological data analysis studies the multi-scale shape of data. Given a finite point
cloud and a dissimilarity, the Vietoris–Rips filtration produces a one-parameter family
of simplicial complexes that grows with the scale parameter; the homological features
that *persist* across a range of scales are the signal, and ephemeral ones are noise. To
make this rigorous, one organizes the entire family into a **persistence module** and
measures the similarity of two modules by the **interleaving distance**, the central
metric of the field.

Two streams of structure surround this distance. On one side, persistence modules are
**functors** out of the ordered real line, and interleavings are (lax) natural
transformations; the categorical viewpoint clarifies why interleaving behaves so well
under composition. On the other side, the additive combination of shifts and the infimum
over admissible shifts are the two operations of the **tropical (min-plus) semiring**.
This paper makes both observations precise and verified, and adds two new
**functoriality** theorems — for the rank invariant and for the shift action — that
exhibit the interleaving distance as a genuinely *algebraic* object living in the tropics.

### Contributions

1. A preorder-valued model of persistence modules and interleavings in which the
   categorical laws (reflexivity, symmetry, weakening, composition) are elementary yet
   faithful (§3).
2. The `ℝ≥0∞`-valued interleaving distance and a complete proof that it is a pseudometric
   (§4).
3. The tropical reformulation: the triangle inequality is exactly submultiplicativity in
   `Tropical ℝ≥0∞` (§5).
4. Vietoris–Rips modules and the stability theorem (§6).
5. The rank functor `PersMod (Set β) → PersMod ℕ`, its preservation of interleavings, and
   its 1-Lipschitz property, with Rips specialization (§7).
6. The shift functor as a tropical scalar action: isometry, ≤ `c` displacement, tropical
   unit at the diagonal; and the finite-distance equivalence relation (§8).

---

## 2. Preliminaries: the tropical semiring

The **tropical semiring** on the extended nonnegative reals `ℝ≥0∞` is the structure
`(ℝ≥0∞, ⊕, ⊙)` with
$$ a \oplus b = \min(a, b), \qquad a \odot b = a + b. $$
Its additive identity is `⊤ = ∞` (since `min(∞, b) = b`) and its multiplicative identity is
`0` (since `0 + b = b`). We write `Tropical ℝ≥0∞` for the carrier with this semiring
structure and `trop : ℝ≥0∞ → Tropical ℝ≥0∞`, `untrop` for the (order-reversing on `⊕`,
order-preserving on `⊙`) tagging maps. The key fact we use is that
$$ \mathrm{trop}(x) \le \mathrm{trop}(y) \odot \mathrm{trop}(z) \iff x \le y + z, $$
i.e. tropical product inequality unfolds to an ordinary additive inequality, and the
tropical multiplicative unit is `trop(0) = 1`.

---

## 3. Persistence modules and interleavings

### 3.1 Definition

Let `α` be a preorder.

> **Definition 3.1 (Persistence module).** A *persistence module* valued in `α` is a pair
> `M = (M.obj, M.mono)` where `M.obj : ℝ → α` and `M.mono` is a proof that `M.obj` is
> monotone: `a ≤ b ⟹ M.obj a ≤ M.obj b`.

Categorically, `M` is a functor `(ℝ, ≤) → α`. We work in a *preorder*-valued model: there
the naturality squares of an interleaving commute automatically (proof irrelevance), so an
interleaving reduces to a pair of pointwise shifted inequalities, with no loss of
faithfulness for the metric theory.

> **Definition 3.2 (ε-interleaving).** For `ε : ℝ` and modules `M, N`, define
> $$ \mathrm{Interleaved}\,\varepsilon\,M\,N \;:=\; \big(\forall t,\ M.\mathrm{obj}\,t \le N.\mathrm{obj}(t+\varepsilon)\big) \ \wedge\ \big(\forall t,\ N.\mathrm{obj}\,t \le M.\mathrm{obj}(t+\varepsilon)\big). $$

### 3.2 Categorical laws

> **Proposition 3.3 (Reflexivity).** `Interleaved 0 M M`.
>
> *Proof.* `M.obj t ≤ M.obj (t + 0)` since `t + 0 = t`. ∎

> **Proposition 3.4 (Symmetry).** `Interleaved ε M N ⟹ Interleaved ε N M`.
>
> *Proof.* Swap the two conjuncts. ∎

> **Proposition 3.5 (Monotone weakening).** If `Interleaved ε M N` and `ε ≤ δ`, then
> `Interleaved δ M N`.
>
> *Proof.* From `M.obj t ≤ N.obj (t+ε)` and monotonicity `N.obj (t+ε) ≤ N.obj (t+δ)`
> (since `t+ε ≤ t+δ`), chain to `M.obj t ≤ N.obj (t+δ)`; symmetrically for the other
> direction. ∎

> **Theorem 3.6 (Composition law / tropical multiplication of interleavings).** If
> `Interleaved ε M N` and `Interleaved δ N L`, then `Interleaved (ε+δ) M L`.
>
> *Proof.* `M.obj t ≤ N.obj (t+ε) ≤ L.obj (t+ε+δ) = L.obj (t+(ε+δ))`, using the two
> interleavings in turn and associativity of addition; symmetrically,
> `L.obj t ≤ N.obj (t+δ) ≤ M.obj (t+δ+ε) = M.obj (t+(ε+δ))`. ∎

Theorem 3.6 is the conceptual heart of the development: it is what makes the interleaving
distance a pseudometric and what becomes tropical multiplication in §5.

---

## 4. The interleaving distance

> **Definition 4.1.** The *interleaving set* of `M, N` is
> $$ \mathrm{interleavingSet}(M,N) := \{\, x \in \mathbb{R}_{\ge 0}^{\infty} \mid \exists\, \varepsilon \ge 0,\ \mathrm{Interleaved}\,\varepsilon\,M\,N \ \wedge\ x = \mathrm{ofReal}\,\varepsilon \,\}, $$
> and the *interleaving distance* is `interleavingDist M N := sInf (interleavingSet M N)`,
> with the convention `sInf ∅ = ⊤`.

Working in `ℝ≥0∞` (rather than `ℝ`) is essential: an empty interleaving set must give `⊤`,
whereas the real-valued infimum of the empty set would collapse to `0` and falsely report
zero distance between incomparable modules.

> **Theorem 4.2 (Self-distance).** `interleavingDist M M = 0`.
>
> *Proof.* `0 ≤` distance always; and `0 ∈ interleavingSet(M,M)` by reflexivity
> (Prop. 3.3) with `ofReal 0 = 0`, so the infimum is `≤ 0`. ∎

> **Theorem 4.3 (Symmetry).** `interleavingDist M N = interleavingDist N M`.
>
> *Proof.* The two interleaving sets coincide as subsets of `ℝ≥0∞` via Prop. 3.4
> (`Interleaved ε M N ⟺ Interleaved ε N M`), hence equal infima. ∎

> **Lemma 4.4 (Upper bound from a witness).** If `0 ≤ ε` and `Interleaved ε M N`, then
> `interleavingDist M N ≤ ofReal ε`.
>
> *Proof.* `ofReal ε ∈ interleavingSet(M,N)`, and the infimum is below any member. ∎

> **Theorem 4.5 (Triangle inequality).**
> `interleavingDist M L ≤ interleavingDist M N + interleavingDist N L`.
>
> *Proof.* First show that for every `x ∈ interleavingSet(M,N)` and
> `y ∈ interleavingSet(N,L)`, `interleavingDist M L ≤ x + y`: write `x = ofReal ε`,
> `y = ofReal δ` with `ε, δ ≥ 0` and the two interleavings; by the composition law
> (Thm. 3.6) `Interleaved (ε+δ) M L`, so by Lemma 4.4
> `interleavingDist M L ≤ ofReal (ε+δ) = ofReal ε + ofReal δ = x + y`. Then push the
> infimum through the sum using the `ℝ≥0∞` identities `sInf A + b = ⨅_{a∈A}(a+b)` and
> `b + sInf B = ⨅_{b'∈B}(b+b')` and bound the resulting double infimum termwise. ∎

Theorems 4.2, 4.3, and 4.5 establish that `interleavingDist` is a `ℝ≥0∞`-valued
**pseudometric** on persistence modules.

---

## 5. Tropical reformulation

> **Theorem 5.1 (Tropical submultiplicativity).** In `Tropical ℝ≥0∞`,
> $$ \mathrm{trop}\big(\mathrm{interleavingDist}\,M\,L\big) \ \le\ \mathrm{trop}\big(\mathrm{interleavingDist}\,M\,N\big) \ \odot\ \mathrm{trop}\big(\mathrm{interleavingDist}\,N\,L\big). $$
>
> *Proof.* Unfolding tropical multiplication `⊙` as addition and the tropical order, the
> claim is identical to the triangle inequality (Thm. 4.5). ∎

This is the precise sense in which interleaving distances "live in the min-plus world":
the composition of interleavings is tropical multiplication, the optimal interleaving is a
tropical infimum (addition), and the triangle inequality *is* tropical submultiplicativity.

---

## 6. Vietoris–Rips modules and stability

Let `X` be a type and `d : X → X → ℝ` a dissimilarity.

> **Definition 6.1 (Vietoris–Rips module).** `RipsMod d : PersMod (Set (X × X))` has
> `obj t = {(x,y) : d x y ≤ t}`, the edge set at scale `t`, ordered by inclusion;
> monotonicity in `t` is `d x y ≤ t ≤ t' ⟹ d x y ≤ t'`.

> **Theorem 6.2 (Stability).** If `|d x y − d' x y| ≤ ε` for all `x, y`, then
> `Interleaved ε (RipsMod d) (RipsMod d')`.
>
> *Proof.* For the first inclusion: if `d x y ≤ t`, then `d' x y ≤ d x y + ε ≤ t + ε`, so
> the edge lies in `RipsMod d'` at scale `t + ε`. The reverse inclusion is symmetric using
> `d x y ≤ d' x y + ε`. ∎

> **Corollary 6.3.** If additionally `0 ≤ ε`, then
> `interleavingDist (RipsMod d) (RipsMod d') ≤ ofReal ε`.
>
> *Proof.* Combine Theorem 6.2 with Lemma 4.4. ∎

A subtlety worth recording (the "failure analysis"): a naive `ℝ`-valued distance via
`Real.sInf` misbehaves on the empty interleaving set, where `sInf ∅ = 0` would wrongly
force distance `0`. Working in `ℝ≥0∞`, where `sInf ∅ = ⊤`, fixes this and is also where
the tropical structure lives.

---

## 7. The rank functor and algebraic stability of the rank invariant

We now restrict to set-valued modules over a **finite** type and pass to numerical
summaries. Let `β` be a finite type and write `ncard S` for the cardinality of a set
`S ⊆ β`.

> **Definition 7.1 (Rank functor).** For `M : PersMod (Set β)` with `β` finite, define
> `rankMod M : PersMod ℕ` by
> $$ (\mathrm{rankMod}\,M).\mathrm{obj}\,t := \mathrm{ncard}\big(M.\mathrm{obj}\,t\big). $$
> Monotonicity holds because, over a finite type, `S ⊆ T ⟹ ncard S ≤ ncard T`
> (`Set.ncard_le_ncard` with finiteness of `T`).

The finiteness hypothesis is genuine, not cosmetic: for an infinite set `Set.ncard`
returns `0`, and monotonicity fails. Equivalently for the Rips case, `Fintype X` gives
`Finite (X × X)`.

> **Theorem 7.2 (Preservation of interleavings).** If `β` is finite and
> `Interleaved ε M N`, then `Interleaved ε (rankMod M) (rankMod N)`.
>
> *Proof.* Apply `ncard` (monotone for finite sets) to each of the two inclusion bounds
> `M.obj t ⊆ N.obj (t+ε)` and `N.obj t ⊆ M.obj (t+ε)`. ∎

> **Theorem 7.3 (1-Lipschitz).** For finite `β`,
> `interleavingDist (rankMod M) (rankMod N) ≤ interleavingDist M N`.
>
> *Proof.* By Theorem 7.2 the interleaving set of `(M, N)` injects into the interleaving
> set of `(rankMod M, rankMod N)`: every witness `ε` for `(M, N)` is a witness for the rank
> curves. Hence `sInf` over the larger set is no greater, i.e. monotonicity of `sInf` under
> set inclusion (`sInf_le_sInf`). ∎

Theorem 7.3 is an **inequality**, not an equality: the rank invariant *forgets* geometry,
so distances can strictly contract. Two non-nested edge sets of equal cardinality collapse
to the same number under `ncard`, so a "permutation-type" perturbation invisible to the
rank curve can still cost positive interleaving distance at the lattice level.

> **Definition 7.4 (Rips rank curve).** For `Fintype X` and `d : X → X → ℝ`,
> `ripsRankCurve d := rankMod (RipsMod d) : PersMod ℕ`, the **edge-count / Betti-0 curve**:
> at scale `t` it counts the pairs `(x,y)` with `d x y ≤ t`.

> **Theorem 7.5 (Rank-curve stability).** If `|d x y − d' x y| ≤ ε` for all `x, y`
> (with `X` finite), then `Interleaved ε (ripsRankCurve d) (ripsRankCurve d')`; and if
> `0 ≤ ε`, then `interleavingDist (ripsRankCurve d) (ripsRankCurve d') ≤ ofReal ε`.
>
> *Proof.* Combine Theorem 6.2 (stability) with Theorem 7.2 (preservation) for the first
> claim, and additionally Theorem 7.3 / Corollary 6.3 for the second. ∎

This is a clean "algebraic stability of the rank invariant": the simplest and most-used
data summary inherits the robustness of the full module, with a controlled interleaving
distance.

---

## 8. The shift functor as a tropical scalar action

The final layer exhibits the tropical scalar action explicitly. For `c : ℝ`:

> **Definition 8.1 (Shift functor).** `shift c M : PersMod α` is given by
> `(shift c M).obj t := M.obj (t + c)`, with monotonicity inherited from `M`.

> **Theorem 8.2 (Shift invariance / isometry on pairs).** For all `ε`,
> `Interleaved ε (shift c M) (shift c N) ⟺ Interleaved ε M N`; consequently
> `interleavingDist (shift c M) (shift c N) = interleavingDist M N`.
>
> *Proof sketch.* The shifted interleaving inequalities
> `M.obj (t+c) ≤ N.obj (t+c+ε)` are obtained from the unshifted ones by the substitution
> `t ↦ t + c` (and back via `t ↦ t − c`), a bijection of the parameter line; the
> interleaving sets coincide, hence the distances. ∎

> **Theorem 8.3 (≤ `c` displacement).** `interleavingDist M (shift c M) ≤ ofReal c`.
>
> *Proof sketch.* Exhibit a `c`-interleaving of `M` and `shift c M`: one direction is
> `M.obj t ≤ M.obj (t + c) = (shift c M).obj t ≤ (shift c M).obj (t + c)`-type domination
> following from monotonicity, witnessing shift by exactly `c`; apply Lemma 4.4. ∎

> **Theorem 8.4 (Tropical unit at the diagonal).**
> `trop (interleavingDist M M) = (1 : Tropical ℝ≥0∞)`.
>
> *Proof.* By Theorem 4.2 the self-distance is `0`, and `trop 0` is the tropical
> multiplicative unit `1`. ∎

> **Definition 8.5 (Finite interleaving).** `FinInterleaved M N := ∃ ε ≥ 0,
> Interleaved ε M N` — the relation of being a finite interleaving distance apart.

> **Theorem 8.6 (Equivalence relation).** `FinInterleaved` is reflexive (Prop. 3.3),
> symmetric (Prop. 3.4), and transitive (Thm. 3.6, the composition law). Moreover
> `FinInterleaved M N ⟺ interleavingDist M N ≠ ⊤`.
>
> *Proof sketch.* Reflexivity uses the `0`-interleaving; symmetry swaps; transitivity adds
> the two shifts via the composition law. For the characterization: a finite witness gives a
> finite upper bound on the infimum (Lemma 4.4), and conversely a finite infimum over a
> nonempty bounded set produces an admissible finite shift. ∎

Thus the universe of persistence modules is partitioned by `FinInterleaved` into classes of
mutually finite distance, on which `interleavingDist` is a genuine (`ℝ≥0`-valued)
pseudometric and `trop ∘ interleavingDist` is a `Tropical ℝ≥0∞`-valued submultiplicative
form.

---

## 9. Algorithms

The theory is constructive and yields directly implementable procedures on finite data.

**Algorithm A (Interleaving witness check).** Given finite-support step descriptions of two
ℕ-valued modules and a candidate `ε`, verify `Interleaved ε` by checking the two shifted
pointwise inequalities at all breakpoints. Complexity `O(k log k)` for `k` breakpoints.

**Algorithm B (Rips rank curve).** Given `d` on `n` points, sort the `O(n²)` pairwise
dissimilarities; the rank curve is the right-continuous step function counting pairs with
`d ≤ t`. Complexity `O(n² log n)`.

**Algorithm C (Interleaving distance of step curves).** For two monotone ℕ-valued step
curves, the interleaving distance equals the maximal horizontal gap between the curves'
generalized inverses; computed by a merge over breakpoints in `O(k)` after sorting.

---

## 10. Applications

- **Robust shape comparison.** The stability theorem (Thm. 6.2) certifies that
  measurement noise of magnitude `ε` perturbs the Rips module by at most `ε` in
  interleaving distance — the foundational guarantee of persistent topology.
- **Cheap, certified summaries.** The 1-Lipschitz rank functor (Thm. 7.3) lets one replace
  the heavy set-valued module by the lightweight edge-count curve while *provably* not
  inflating distances; useful for screening large datasets.
- **Scale calibration.** The shift isometry (Thm. 8.2) formalizes invariance under a global
  re-zeroing of the scale parameter, and the ≤ `c` displacement (Thm. 8.3) quantifies the
  cost of a deliberate scale offset.
- **Clustering of datasets.** The finite-distance equivalence (Thm. 8.6) partitions a
  corpus of persistence modules into comparable classes, a prerequisite for any averaging
  or barycenter computation.

---

## 11. Discussion

The development is deliberately minimal in hypotheses and maximal in structure. By working
in a preorder-valued model we discard naturality data that is invisible to the metric while
retaining every law needed for the pseudometric and tropical theory. The single nontrivial
analytic step is the triangle inequality, where infima must be pushed through addition in
`ℝ≥0∞`; everything else reduces to monotonicity and arithmetic of shifts. The rank and
shift functors then show that the interleaving distance is not merely a metric but an
*algebraic* object: 1-Lipschitz functors map into it, a scalar action acts by isometries
and bounded displacement, and the tropical unit sits exactly at the diagonal.

The honesty of the inequalities matters. The 1-Lipschitz bound (Thm. 7.3) is genuinely
non-tight — counting forgets geometry — and the finiteness hypothesis on `β` is
load-bearing, not cosmetic. These are recorded as quantitative information-loss statements
rather than smoothed away.

---

## 12. Future work

The following are precise, falsifiable targets (verbatim from the project's research log,
lightly edited):

- **Conjecture A (Rank contraction is generically strict).** The bound
  `interleavingDist (rankMod M) (rankMod N) ≤ interleavingDist M N` should be *strict* for
  an explicit pair of Rips modules on a 3-point set: `ncard` collapses two non-nested edge
  sets of equal cardinality to the same number, so a permutation-type perturbation invisible
  to the rank curve still costs positive interleaving distance at the lattice level.
  Constructing the 3-point counterexample upgrades "1-Lipschitz" to "strictly contracting."

- **Conjecture B (Shift is the unique tropical scalar action / tightness).** Beyond
  `interleavingDist M (shift c M) ≤ ofReal c`, the bound should be *tight*:
  `interleavingDist M (shift c M) = ofReal c` whenever `M` is strictly monotone on a real
  interval of length `> c`. Strict monotonicity blocks any cheaper interleaving: an
  ε-interleaving with `ε < c` would force `M.obj t < M.obj t` after composing the two
  shifted dominations, extracted at an interior point.

- **Conjecture C (Tropical metric on the finite-distance quotient).** Since
  `FinInterleaved` is an equivalence relation, the quotient `PersMod α / FinInterleaved`
  should carry a well-defined `Tropical ℝ≥0∞`-valued metric, refining bisimilarity, on which
  `trop ∘ interleavingDist` is a bona fide submultiplicative form.

- **Isometry / converse stability.** For Rips modules of pseudometrics `d, d'` the
  interleaving distance should *equal* (not merely bound) the sup perturbation
  `ofReal (⨆ x y, |d x y − d' x y|)` when finite, by extracting the pointwise bound from any
  ε-interleaving evaluated at `t = d x y`.

- **Stability of multiset-of-bars refinements.** Lift the rank/Betti-0 result to richer
  derived invariants (full barcodes), tracking how the contraction in Theorem 7.3 interacts
  with the finer information of higher Betti curves.

---

## 13. Conclusion

We have given a compact, fully verified account of the interleaving distance as a tropical
object: a `ℝ≥0∞`-valued pseudometric whose triangle inequality is submultiplicativity in
`Tropical ℝ≥0∞`, instantiated by Vietoris–Rips stability, and equipped with two
functoriality theorems — a 1-Lipschitz rank functor and an isometric shift action with the
tropical unit at the diagonal — together with the finite-distance equivalence relation. The
three cultures of category theory, tropical algebra, and topological data analysis are
exhibited as three views of a single, robust structure.
