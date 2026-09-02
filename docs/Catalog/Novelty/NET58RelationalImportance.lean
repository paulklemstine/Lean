import Novelty.ProbeRetentionLimits

/-!
# NET-58: importance is relational, not intrinsic

Round 11 of the limited-memory axis (paper 143) fitted, for every
`(layer, kv-head)` cell of a 0.5B transformer, a ridge probe from the 64-dimensional
post-rope key vector to `log1p(total future attention)`, and then evicted the KV cache by
the resulting **static** score.  The measured table (retained attention mass, ctx = 1024):

| `B` | accumulated-HH (NET-56) | static probe | oracle |
|-----|-------------------------|--------------|--------|
| 32  | 0.8633                  | 0.8395       | 0.9913 |
| 64  | 0.8822                  | 0.8938       | 0.9953 |
| 128 | 0.9189                  | 0.9284       | —      |

with probe `R²` mean `0.329` (min `0.113`, max `0.639`).  The pre-registered horn `P1`
("a content probe closes ≥ 33 % of the oracle gap") was **refuted**: at `B = 64` the probe
closes `10.26 %`, and at `B = 32` it is *worse* than doing nothing content-wise.  The verdict
was named `CONTENT-IS-A-WEAK-PREDICTOR-OF-IMPORTANCE`.

`Novelty.ProbeRetentionLimits` already converts an `R²` into a *retention* guarantee, and
`Novelty.ProbeHybridStability` shows that accuracy alone does not order retention.  What was
missing — and is proved here — is the **structural ceiling** of the whole content-based family:
why the gap is not an engineering shortfall.

Two independent ceilings are established, and then identified with one another.

## The relational ceiling (§1)

Model a run as a family of *contexts* `w : W` sharing one set of key contents `i : ι`, with
per-context true importances `a w i`.  A **static** (content-only) score commits to one
selection `S` for all contexts — this is exactly what a probe fitted on train-side windows
does.  Then:

* `avgRetained_const` — a static selection retains, on average over contexts, exactly the mass
  that `S` carries for the **average** importance profile `avgImportance a`.  All
  context-conditional information is annihilated: a static policy sees only the mean profile.
* `static_le_meanOracle`, `meanOracle_le_avgOracle`, `static_content_ceiling` — hence
  `static ≤ (top-B set of the mean profile) ≤ (average over contexts of the per-context
  oracle)`.  The middle quantity is the **ceiling of the entire content-only family**, and the
  final inequality is a Jensen gap for the `max`-functional.
* `relationalDeficit_nonneg`, `relationalDeficit_ge_single_context` — the deficit is
  nonnegative and already bounded below by the loss suffered in one single context.
* `swap_static_retained`, `swap_relational_deficit` — a fully explicit witness: two contexts in
  which the same two key contents exchange roles.  Every static score retains `(u+v)/2`, the
  oracle retains `u`, and the deficit is exactly `(u-v)/2 > 0`, *for every* `u > v`.  Nothing
  about the score class is used: linear, nonlinear, ridge or neural probes all sit here.

## The intrinsic (ANOVA) ceiling (§2)

Independently, fix a content map `key : ι → κ` and let a score be *any* function of the key,
`s = f ∘ key` (no linearity).  Then

* `ssWithin_le_sse` — the within-fiber sum of squares lower-bounds the squared error of every
  content-measurable score, and
* `sse_condMean` — the conditional mean attains it, so
* `Rsq_le_intrinsic_ceiling` / `intrinsic_ceiling_attained` — `1 - SS_within/SS_tot` is exactly
  the supremum of `R²` over *all* content functions.  The measured `R² = 0.329` of a linear
  ridge probe is a lower bound for this ceiling; barrier (c) (linear probe class only) is
  therefore confronted structurally: nonlinearity can help only up to the ANOVA ceiling.
* `ssWithin_eq_zero_of_injective` — the honest caveat: *within a single context* all key vectors
  are distinct, the ceiling is vacuous, and nothing can be concluded.  The ceiling has content
  only for the pooled, multi-context population, which is precisely how the probe was fitted.

## The identification (§3)

* `pooled_ssWithin_le`, `pooled_condMean_optimal` — pooled over contexts, the best
  content-measurable predictor of importance **is** `avgImportance a`, and its irreducible error
  is the context dispersion `∑ᵢ ∑_w (a w i - ā i)²`.  So §2's ANOVA ceiling and §1's relational
  ceiling are the same object seen twice: *what content cannot know is the context*.

## The measured numbers (§4)

* `closure_le_one_sub_deficit` — a positive relational deficit caps the closure fraction of the
  oracle gap strictly below 1, for every content probe present and future.
* `net58_P1_refuted`, `net58_probe_hurts_at_B32`, `net58_P2_confirmed` — the three horns in the
  currency of the round: `10.26 % < 33 %`, a negative closure at `B = 32`, and `> 10` points
  still open at `B = 64`.
* `net58_static_improvement_bound` — the deployment corollary: at `B = 64` no content-only score
  whatsoever can retain more than the ceiling, so the residual `0.1015` is split into a part
  that a better probe might recover and a part (`relationalDeficit`) that is provably closed.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the probe's failure is not a failure of the *fit* but of the
*hypothesis class*: any score that is a function of the key vector alone predicts the
context-averaged importance at best, and the residual — the Jensen gap of the `max`-functional
over contexts — is a structural constant of the population.

Experiment (Experimenter): `ComputationalEvidence.md` re-derives the closure fractions from the
measured table (`+10.26 %` at `B = 64`, `-18.59 %` at `B = 32`), checks the two-context swap
witness numerically, and verifies the crossing instance used in
`Novelty.NET58BudgetCrossing`.

Analysis (Analyst): the refutation of `P1` is *not* explained by the size of `1 - R² = 0.671`
(`Novelty.ProbeRetentionLimits.exists_probe_perfect_retention_with_Rsq` shows a probe with the
same `R²` can be perfect).  It is explained by `static_content_ceiling`: a static score is
evaluated against a *distribution* of contexts, and the maximum of the average is below the
average of the maxima.  "True but hard" for a better probe; "false" for the whole family.

Critique (Critic): the ANOVA ceiling would be vacuous if applied inside one context
(`ssWithin_eq_zero_of_injective`), and the relational ceiling would be vacuous if all contexts
agreed (then `relationalDeficit = 0`, and `swap_relational_deficit` shows this is exactly the
degenerate case `u = v`).  Both caveats are theorems here rather than footnotes.  No result
below is an equality by definition: `avgRetained_const` is a sum interchange,
`static_content_ceiling` chains two genuinely different inequalities, and the witness is
parametric in `u > v` rather than numeric.
-/

namespace Catalog.Novelty.NET58RelationalImportance

open Finset Catalog.Novelty.ProbeRetentionLimits

/-! ### 1. Contexts, static scores, and the relational ceiling -/

section Relational

variable {ι : Type*} {W : Type*} [Fintype W]

/-- The context-averaged importance profile: the only thing a static score can see. -/
noncomputable def avgImportance (a : W → ι → ℝ) : ι → ℝ :=
  fun i => (∑ w, a w i) / Fintype.card W

/-- Average retained mass of a (possibly context-dependent) selection policy. -/
noncomputable def avgRetained (a : W → ι → ℝ) (S : W → Finset ι) : ℝ :=
  (∑ w, retained (a w) (S w)) / Fintype.card W

/-- **A static selection sees only the mean profile.**  Averaged over contexts, the mass
retained by a fixed set `S` equals the mass `S` carries in the averaged importance profile. -/
theorem avgRetained_const (a : W → ι → ℝ) (S : Finset ι) :
    avgRetained a (fun _ => S) = retained (avgImportance a) S := by
  unfold avgRetained retained avgImportance
  rw [Finset.sum_comm, Finset.sum_div]

private lemma div_card_le_div_card {x y : ℝ} (h : x ≤ y) :
    x / Fintype.card W ≤ y / Fintype.card W := by
  rcases Nat.eq_zero_or_pos (Fintype.card W) with h0 | h0
  · simp [h0]
  · exact (div_le_div_iff_of_pos_right (by exact_mod_cast h0)).mpr h

/-- Averaging preserves the pointwise oracle bound. -/
theorem avgRetained_le_avgOracle (a : W → ι → ℝ) {B : ℕ} {S : W → Finset ι}
    (hS : ∀ w, (S w).card = B) {O : W → Finset ι} (hO : ∀ w, IsTopSet (a w) B (O w)) :
    avgRetained a S ≤ avgRetained a O :=
  div_card_le_div_card
    (Finset.sum_le_sum fun w _ => retained_le_of_isTopSet_true (hO w) (hS w))

/-- **Step 1 of the ceiling.**  Every static selection is dominated by the top-`B` set of the
*mean* profile. -/
theorem static_le_meanOracle (a : W → ι → ℝ) {B : ℕ} {S T : Finset ι}
    (hS : S.card = B) (hT : IsTopSet (avgImportance a) B T) :
    avgRetained a (fun _ => S) ≤ retained (avgImportance a) T := by
  rw [avgRetained_const]
  exact retained_le_of_isTopSet_true hT hS

/-- **Step 2 of the ceiling: the Jensen gap.**  The best static selection — the top-`B` set of
the mean profile — is still below the context-wise oracle.  The maximum of an average never
exceeds the average of the maxima. -/
theorem meanOracle_le_avgOracle (a : W → ι → ℝ) {B : ℕ} {T : Finset ι}
    (hT : IsTopSet (avgImportance a) B T) {O : W → Finset ι}
    (hO : ∀ w, IsTopSet (a w) B (O w)) :
    retained (avgImportance a) T ≤ avgRetained a O := by
  rw [← avgRetained_const]
  exact avgRetained_le_avgOracle a (fun _ => hT.card) hO

/-- **The relational ceiling.**  No score that is fixed across contexts — in particular no
score computed from key content alone, of any functional form — retains more, on average, than
the top-`B` set of the mean profile, and that ceiling is itself below the oracle. -/
theorem static_content_ceiling (a : W → ι → ℝ) {B : ℕ} {S T : Finset ι}
    (hS : S.card = B) (hT : IsTopSet (avgImportance a) B T) {O : W → Finset ι}
    (hO : ∀ w, IsTopSet (a w) B (O w)) :
    avgRetained a (fun _ => S) ≤ retained (avgImportance a) T ∧
      retained (avgImportance a) T ≤ avgRetained a O :=
  ⟨static_le_meanOracle a hS hT, meanOracle_le_avgOracle a hT hO⟩

/-- The structural part of the oracle gap: what remains after the *best possible* content-only
score has been deployed. -/
noncomputable def relationalDeficit (a : W → ι → ℝ) (O : W → Finset ι) (T : Finset ι) : ℝ :=
  avgRetained a O - retained (avgImportance a) T

theorem relationalDeficit_nonneg (a : W → ι → ℝ) {B : ℕ} {T : Finset ι}
    (hT : IsTopSet (avgImportance a) B T) {O : W → Finset ι}
    (hO : ∀ w, IsTopSet (a w) B (O w)) : 0 ≤ relationalDeficit a O T := by
  have := meanOracle_le_avgOracle a hT hO
  simp only [relationalDeficit]
  linarith

/-- **One bad context suffices.**  The deficit is bounded below by the loss the mean-profile
selection suffers in any single context, divided by the number of contexts. -/
theorem relationalDeficit_ge_single_context (a : W → ι → ℝ) {B : ℕ} {T : Finset ι}
    (hT : IsTopSet (avgImportance a) B T) {O : W → Finset ι}
    (hO : ∀ w, IsTopSet (a w) B (O w)) (w₀ : W) :
    (retained (a w₀) (O w₀) - retained (a w₀) T) / Fintype.card W
      ≤ relationalDeficit a O T := by
  have hterm : ∀ w ∈ (Finset.univ : Finset W),
      retained (a w) T ≤ retained (a w) (O w) := fun w _ =>
    retained_le_of_isTopSet_true (hO w) hT.card
  have hsingle : retained (a w₀) (O w₀) - retained (a w₀) T
      ≤ ∑ w, (retained (a w) (O w) - retained (a w) T) := by
    refine Finset.single_le_sum (f := fun w => retained (a w) (O w) - retained (a w) T)
      (fun w hw => by linarith [hterm w hw]) (Finset.mem_univ w₀)
  have hsplit : ∑ w, (retained (a w) (O w) - retained (a w) T)
      = (∑ w, retained (a w) (O w)) - ∑ w, retained (a w) T := by
    rw [Finset.sum_sub_distrib]
  have hstat : (∑ w, retained (a w) T) / Fintype.card W = retained (avgImportance a) T := by
    have := avgRetained_const a T
    simpa [avgRetained] using this
  have hgoal := div_card_le_div_card (W := W) (hsingle.trans_eq hsplit)
  simp only [relationalDeficit, avgRetained]
  rw [← hstat, ← sub_div]
  exact hgoal

end Relational

/-! ### 1b.  The swap witness: two contexts, two key contents, exchanged roles -/

section Swap

/-- Two contexts in which the two key contents exchange importance: content `0` dominates in
context `0`, content `1` dominates in context `1`.  Nothing distinguishes them on average. -/
noncomputable def swapImp (u v : ℝ) : Fin 2 → Fin 2 → ℝ := ![![u, v], ![v, u]]

@[simp] lemma swapImp_avg (u v : ℝ) (i : Fin 2) : avgImportance (swapImp u v) i = (u + v) / 2 := by
  fin_cases i <;> simp [avgImportance, swapImp, Fin.sum_univ_two, add_comm]

/-- The per-context oracle for the swap pair at budget `1`. -/
def swapOracle : Fin 2 → Finset (Fin 2) := ![{0}, {1}]

lemma swapOracle_isTopSet {u v : ℝ} (h : v ≤ u) (w : Fin 2) :
    IsTopSet (swapImp u v w) 1 (swapOracle w) := by
  refine ⟨?_, ?_⟩
  · fin_cases w <;> decide
  · intro i hi j hj
    fin_cases w <;> fin_cases i <;> fin_cases j <;> simp_all [swapImp, swapOracle]

/-- **Every static score retains the average.**  At budget `1` there are only two selections and
both retain exactly `(u+v)/2` — the score class is irrelevant. -/
theorem swap_static_retained (u v : ℝ) {S : Finset (Fin 2)} (hS : S.card = 1) :
    avgRetained (swapImp u v) (fun _ => S) = (u + v) / 2 := by
  obtain ⟨x, rfl⟩ := Finset.card_eq_one.mp hS
  rw [avgRetained_const]
  fin_cases x <;> simp [retained]

/-- The oracle retains the maximum in each context. -/
theorem swap_oracle_retained (u v : ℝ) :
    avgRetained (swapImp u v) swapOracle = u := by
  simp [avgRetained, retained, swapOracle, swapImp, Fin.sum_univ_two]

/-- **The relational law, exactly.**  For every `u > v` the gap between the oracle and *every*
content-only policy is exactly `(u-v)/2`, and it is positive.  Importance is relational: the
same key content is worth `u` in one context and `v` in another, and no function of the content
can tell which. -/
theorem swap_relational_deficit (u v : ℝ) (huv : v < u) {S : Finset (Fin 2)} (hS : S.card = 1) :
    avgRetained (swapImp u v) swapOracle - avgRetained (swapImp u v) (fun _ => S)
      = (u - v) / 2 ∧
    0 < avgRetained (swapImp u v) swapOracle - avgRetained (swapImp u v) (fun _ => S) := by
  rw [swap_oracle_retained, swap_static_retained u v hS]
  constructor
  · ring
  · linarith

/-- The witness is a genuine instance of the general model: `swapOracle` really is the oracle. -/
theorem swap_is_oracle_instance {u v : ℝ} (h : v ≤ u) :
    ∀ w, IsTopSet (swapImp u v w) 1 (swapOracle w) := swapOracle_isTopSet h

/-- **Static/adaptive separation.**  The very same budget, the same keys and the same contexts:
a policy allowed to re-rank per context attains the oracle exactly, while every static policy —
every content probe — falls strictly short.  What the probe lacks is not accuracy but the right
to depend on the context; this is the formal counterpart of the deployment advice "track usage
online". -/
theorem swap_adaptive_beats_every_static (u v : ℝ) (huv : v < u) {S : Finset (Fin 2)}
    (hS : S.card = 1) :
    (∀ w, IsTopSet (swapImp u v w) 1 (swapOracle w)) ∧
      avgRetained (swapImp u v) (fun _ => S) < avgRetained (swapImp u v) swapOracle := by
  refine ⟨swapOracle_isTopSet (le_of_lt huv), ?_⟩
  rw [swap_oracle_retained, swap_static_retained u v hS]
  linarith

end Swap

/-! ### 2.  The intrinsic ceiling: what *any* function of the key can explain -/

section Anova

variable {ι : Type*} [Fintype ι] {κ : Type*} [Fintype κ] [DecidableEq κ]

/-- The **mean is the best constant**: for any finite block, the squared error around the block
mean is minimal.  This one inequality drives the whole section. -/
theorem sum_sq_mean_le {α : Type*} (G : Finset α) (g : α → ℝ) (c : ℝ) :
    ∑ i ∈ G, (g i - (∑ j ∈ G, g j) / G.card) ^ 2 ≤ ∑ i ∈ G, (g i - c) ^ 2 := by
  rcases eq_or_ne G.card 0 with h0 | h0
  · rw [Finset.card_eq_zero.mp h0]; simp
  have hN : ((G.card : ℝ)) ≠ 0 := Nat.cast_ne_zero.mpr h0
  set m : ℝ := (∑ j ∈ G, g j) / G.card with hm
  have hsum : ∑ j ∈ G, g j = (G.card : ℝ) * m := by rw [hm]; field_simp
  have key : ∑ i ∈ G, ((g i - c) ^ 2 - (g i - m) ^ 2) = (G.card : ℝ) * (m - c) ^ 2 := by
    have h1 : ∀ i, (g i - c) ^ 2 - (g i - m) ^ 2 = 2 * (m - c) * g i + (c ^ 2 - m ^ 2) := by
      intro i; ring
    simp_rw [h1]
    rw [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_const, nsmul_eq_mul, hsum]
    ring
  rw [Finset.sum_sub_distrib] at key
  nlinarith [sq_nonneg (m - c), Nat.cast_nonneg (α := ℝ) G.card]

/-- The keys sharing a given content value. -/
def fiber (key : ι → κ) (y : κ) : Finset ι := Finset.univ.filter (fun i => key i = y)

/-- The average importance of the keys with content `y`: the best a content score can do there. -/
noncomputable def condMean (key : ι → κ) (a : ι → ℝ) (y : κ) : ℝ :=
  (∑ i ∈ fiber key y, a i) / (fiber key y).card

/-- Within-content dispersion of the importances: the part of the variance no function of the
content can ever explain. -/
noncomputable def ssWithin (key : ι → κ) (a : ι → ℝ) : ℝ :=
  ∑ y, ∑ i ∈ fiber key y, (a i - condMean key a y) ^ 2

theorem ssWithin_nonneg (key : ι → κ) (a : ι → ℝ) : 0 ≤ ssWithin key a :=
  Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _

/-- **The ANOVA bound.**  Every content-measurable score `f ∘ key` — linear ridge probe,
nonlinear head, lookup table, anything — has squared error at least the within-content
dispersion. -/
theorem ssWithin_le_sse (key : ι → κ) (a : ι → ℝ) (f : κ → ℝ) :
    ssWithin key a ≤ sse a (fun i => f (key i)) := by
  have hfib : sse a (fun i => f (key i))
      = ∑ y : κ, ∑ i ∈ fiber key y, (a i - f (key i)) ^ 2 := by
    rw [sse, ← Finset.sum_fiberwise Finset.univ key (fun i => (a i - f (key i)) ^ 2)]
    rfl
  rw [hfib, ssWithin]
  refine Finset.sum_le_sum fun y _ => ?_
  have hcong : ∑ i ∈ fiber key y, (a i - f (key i)) ^ 2
      = ∑ i ∈ fiber key y, (a i - f y) ^ 2 :=
    Finset.sum_congr rfl fun i hi => by rw [(Finset.mem_filter.mp hi).2]
  rw [hcong]
  exact sum_sq_mean_le _ a (f y)

/-- The bound is attained by the conditional mean, which is itself content-measurable. -/
theorem sse_condMean (key : ι → κ) (a : ι → ℝ) :
    sse a (fun i => condMean key a (key i)) = ssWithin key a := by
  rw [sse, ← Finset.sum_fiberwise Finset.univ key
    (fun i => (a i - condMean key a (key i)) ^ 2), ssWithin]
  exact Finset.sum_congr rfl fun y _ =>
    Finset.sum_congr rfl fun i hi => by rw [(Finset.mem_filter.mp hi).2]

/-- **The intrinsic `R²` ceiling.**  No content-measurable score, of any functional form,
exceeds `1 - SS_within / SS_tot`.  Barrier (c) of the round — "linear probe class only" — is
thereby closed: nonlinearity buys at most the distance from the measured `0.329` to this
ceiling. -/
theorem Rsq_le_intrinsic_ceiling (key : ι → κ) (a : ι → ℝ) (f : κ → ℝ) (h : 0 < sstot a) :
    Rsq a (fun i => f (key i)) ≤ 1 - ssWithin key a / sstot a := by
  have hs := ssWithin_le_sse key a f
  have : ssWithin key a / sstot a ≤ sse a (fun i => f (key i)) / sstot a := by
    exact (div_le_div_iff_of_pos_right h).mpr hs
  simp only [Rsq]
  linarith

/-- The ceiling is exactly the supremum: it is attained. -/
theorem intrinsic_ceiling_attained (key : ι → κ) (a : ι → ℝ) :
    Rsq a (fun i => condMean key a (key i)) = 1 - ssWithin key a / sstot a := by
  simp [Rsq, sse_condMean key a]

/-- **The honest caveat.**  Inside a single context all key vectors are distinct, the fibers are
singletons, and the intrinsic ceiling degenerates to `R² ≤ 1`: it says nothing.  The ceiling has
content only for a population that repeats contents across contexts — which is exactly the
pooled train/test window population the probe was fitted on. -/
theorem ssWithin_eq_zero_of_injective {key : ι → κ} (hkey : Function.Injective key)
    (a : ι → ℝ) : ssWithin key a = 0 := by
  refine Finset.sum_eq_zero fun y _ => ?_
  rcases (fiber key y).eq_empty_or_nonempty with he | ⟨i, hi⟩
  · simp [he]
  · have hsingle : fiber key y = {i} := by
      refine Finset.eq_singleton_iff_unique_mem.mpr ⟨hi, fun x hx => ?_⟩
      have h1 : key x = y := (Finset.mem_filter.mp hx).2
      have h2 : key i = y := (Finset.mem_filter.mp hi).2
      exact hkey (h1.trans h2.symm)
    simp [hsingle, condMean]

end Anova

/-! ### 3.  The two ceilings are one: pooled content prediction is context averaging -/

section Pooled

variable {ι : Type*} [Fintype ι] {W : Type*} [Fintype W]

/-- **Identification theorem.**  Pooled over contexts, the best content-only predictor of the
true importance is the context average `avgImportance a`, and its irreducible squared error is
the context dispersion.  §2's `SS_within` *is* §1's relational information. -/
theorem pooled_ssWithin_le (a : W → ι → ℝ) (f : ι → ℝ) :
    ∑ i, ∑ w, (a w i - avgImportance a i) ^ 2 ≤ ∑ i, ∑ w, (a w i - f i) ^ 2 := by
  refine Finset.sum_le_sum fun i _ => ?_
  have h := sum_sq_mean_le (Finset.univ : Finset W) (fun w => a w i) (f i)
  simpa [avgImportance, Finset.card_univ] using h

/-- The optimum is attained by the context average, so the inequality above is sharp. -/
theorem pooled_condMean_optimal (a : W → ι → ℝ) :
    IsLeast {e : ℝ | ∃ f : ι → ℝ, e = ∑ i, ∑ w, (a w i - f i) ^ 2}
      (∑ i, ∑ w, (a w i - avgImportance a i) ^ 2) :=
  ⟨⟨avgImportance a, rfl⟩, by rintro e ⟨f, rfl⟩; exact pooled_ssWithin_le a f⟩

end Pooled

/-! ### 4.  The measured NET-58 numbers -/

section Measured

/-- Fraction of the oracle gap that a policy closes over a baseline. -/
noncomputable def closureFraction (base policy oracle : ℝ) : ℝ :=
  (policy - base) / (oracle - base)

/-- **A structural deficit caps every content probe.**  If a policy is capped `d` below the
oracle, its closure fraction is at most `1 - d/(oracle - base)`; a positive `d` therefore keeps
the whole family strictly away from `1`, forever. -/
theorem closure_le_one_sub_deficit {base policy oracle d : ℝ} (hbo : base < oracle)
    (hcap : policy ≤ oracle - d) :
    closureFraction base policy oracle ≤ 1 - d / (oracle - base) := by
  have hpos : 0 < oracle - base := by linarith
  rw [closureFraction, div_le_iff₀ hpos]
  field_simp
  linarith

/-- **P1 refuted.**  At `B = 64` the static probe closes `10.26 %` of the oracle gap over the
accumulated-HH baseline — far below the pre-registered `33 %`. -/
theorem net58_P1_refuted :
    closureFraction 0.8822 0.8938 0.9953 < 1 / 3 := by
  rw [closureFraction]
  norm_num

/-- The measured closure is positive but small: the probe does help at `B = 64`. -/
theorem net58_closure_B64_positive :
    0 < closureFraction 0.8822 0.8938 0.9953 := by
  rw [closureFraction]
  norm_num

/-- **P1 refuted, second horn.**  At `B = 32` the probe is *worse* than the accumulation
baseline: the closure fraction is negative. -/
theorem net58_probe_hurts_at_B32 :
    closureFraction 0.8633 0.8395 0.9913 < 0 := by
  rw [closureFraction]
  norm_num

/-- **P2 confirmed.**  More than ten points of retained mass separate the probe from the oracle
at `B = 64`. -/
theorem net58_P2_confirmed : (0.10 : ℝ) < 0.9953 - 0.8938 := by norm_num

/-- **Deployment corollary.**  In the multi-context model, calibrated to the measured `B = 64`
row, every content-only score — the measured ridge probe, and every future replacement for it —
retains at most `0.9953 - relationalDeficit`, so the reported `0.1015`-point residual splits
into a recoverable part and a provably closed part. -/
theorem net58_static_improvement_bound {ι W : Type*} [Fintype ι] [Fintype W]
    (a : W → ι → ℝ) {S T : Finset ι} (hS : S.card = 64)
    (hT : IsTopSet (avgImportance a) 64 T) {O : W → Finset ι}
    (hO : ∀ w, IsTopSet (a w) 64 (O w)) (horacle : avgRetained a O = 0.9953) :
    avgRetained a (fun _ => S) ≤ 0.9953 - relationalDeficit a O T ∧
      0 ≤ relationalDeficit a O T := by
  have h1 := static_le_meanOracle a hS hT
  refine ⟨?_, relationalDeficit_nonneg a hT hO⟩
  simp only [relationalDeficit, horacle]
  linarith

end Measured

end Catalog.Novelty.NET58RelationalImportance