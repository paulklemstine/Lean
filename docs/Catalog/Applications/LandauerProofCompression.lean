import Mathlib

/-!
# Landauer's Principle for Proof Compression

This file gives a rigorous information-thermodynamic analysis of the conjecture

> *the minimum energy required to compress a proof of `n` steps into a proof of `m`
> steps (`m < n`) is at least `k·T·(n-m)·log 2`, and this bound is tight, independently
> of the proof system.*

The physical content of Landauer's principle is that a **logically irreversible**
map dissipates at least `k·T` times the *information erased*, measured in nats.
For a deterministic map `f : Src → Tgt` fed with the uniform distribution on a finite
set `Src`, the information erased is the conditional entropy

`H(X ∣ f X) = (1/|Src|) * ∑_{x ∈ Src} log |f⁻¹(f x)|`,

which is exactly `erasedNats f` below.

## What is proved

* `erasedNats_nonneg`, `erasedNats_eq_zero_iff` — erasure is nonnegative, and vanishes
  precisely for logically reversible (injective) compressions.
* `erasedNats_ge_log_ratio` — **the counting form of Landauer's principle**: the erased
  information is at least `log |Src| - log |image f|`.  This is proved from scratch via
  the Gibbs inequality in the elementary form `log t ≤ t - 1`; it is *not* the naive
  bound `log(|Src|/|image f|)` obtained by assuming equal fibers, and it holds for
  arbitrary fiber-size profiles.
* `erasedNats_le_log_card` — the matching universal upper bound.
* `erasedNats_mono_comp` — compressing further never erases less.
* `bennett_reversible_implementation` — Bennett's escape: every compression admits a
  logically reversible implementation of **zero** erasure, at the price of retaining
  the history.
* `naiveLandauerProofCompression_false` — **the conjecture as stated is false**: a proof
  system that is rigid (few proofs of length `n`) can be compressed for free.  The
  hypothesis "a proof of length `n` carries `n` bits" is a statement about the *proof
  space*, not about the number `n`.
* `landauer_compression_bound_of_redundancy` — the corrected, guarded statement: as soon
  as the space of `n`-step proofs is `2^(n-m)` times larger than the space of `m`-step
  proofs, the conjectured bound `k·T·(n-m)·log 2` does hold.
* `binary_landauer_bound_isLeast` — for a *full binary* proof space the bound is **exactly
  tight**: `(n-m)·log 2` is the least erasure over all surjective compressions, attained
  by truncation.
* `branching_erasure_eq`, `branching_beats_naive_bound` — with branching factor `b` the
  true cost is `(n-m)·log b`, so for `b ≥ 3` the conjectured bound is a strict
  underestimate.  Proof length alone does not determine the thermodynamic cost.
* `fta_compression_heat_eq`, `fta_compression_heat_bracket` — the requested numeric
  instance: compressing a full-binary 1000-step proof (e.g. of the fundamental theorem of
  algebra) to 100 steps at `T = 300 K` dissipates exactly `900 kB T log 2`, i.e.
  `2.5838…×10⁻¹⁸ J`.

## References

* R. Landauer, *Irreversibility and heat generation in the computing process* (1961).
* C. H. Bennett, *Logical reversibility of computation* (1973).
-/

namespace LandauerProofCompression

open Finset Real

/-! ## Erasure of a deterministic map -/

variable {α β γ : Type*} [Fintype α] [DecidableEq β]

/-- The fiber of `f` over `y`, as a finite set of "microstates" of the source. -/
def fiber (f : α → β) (y : β) : Finset α := {x ∈ Finset.univ | f x = y}

/-- The information (in nats) erased by the deterministic map `f`, i.e. the conditional
entropy `H(X ∣ f X)` of a uniformly distributed input `X`. -/
noncomputable def erasedNats (f : α → β) : ℝ :=
  (∑ x : α, Real.log ((fiber f (f x)).card)) / Fintype.card α

/-- The information erased, measured in bits. -/
noncomputable def erasedBits (f : α → β) : ℝ := erasedNats f / Real.log 2

/-- Landauer heat: the minimal heat dissipated when running `f` irreversibly at
temperature `T` with Boltzmann constant `kB`. -/
noncomputable def landauerHeat (kB T : ℝ) (f : α → β) : ℝ := kB * T * erasedNats f

lemma mem_fiber {f : α → β} {x : α} {y : β} : x ∈ fiber f y ↔ f x = y := by simp [fiber]

lemma fiber_card_pos (f : α → β) (x : α) : 0 < (fiber f (f x)).card :=
  Finset.card_pos.mpr ⟨x, mem_fiber.mpr rfl⟩

lemma log_fiber_nonneg (f : α → β) (x : α) : 0 ≤ Real.log ((fiber f (f x)).card) := by
  apply Real.log_nonneg
  exact_mod_cast fiber_card_pos f x

/-- Erasure is never negative: a deterministic step cannot create information. -/
theorem erasedNats_nonneg (f : α → β) : 0 ≤ erasedNats f := by
  apply div_nonneg
  · exact Finset.sum_nonneg fun x _ => log_fiber_nonneg f x
  · positivity

/-- Landauer heat is nonnegative at nonnegative temperature. -/
theorem landauerHeat_nonneg (kB T : ℝ) (hkB : 0 ≤ kB) (hT : 0 ≤ T) (f : α → β) :
    0 ≤ landauerHeat kB T f :=
  mul_nonneg (mul_nonneg hkB hT) (erasedNats_nonneg f)

/-- **Logical reversibility ↔ zero cost.**  A compression is free precisely when it is
injective, i.e. when no information is destroyed. -/
theorem erasedNats_eq_zero_iff [Nonempty α] (f : α → β) :
    erasedNats f = 0 ↔ Function.Injective f := by
  constructor
  · intro h
    have hc : (Fintype.card α : ℝ) ≠ 0 := by
      have : 0 < Fintype.card α := Fintype.card_pos
      positivity
    have hsum : ∑ x : α, Real.log ((fiber f (f x)).card) = 0 := by
      rcases div_eq_zero_iff.mp h with h' | h'
      · exact h'
      · exact absurd h' hc
    have hz : ∀ x : α, Real.log ((fiber f (f x)).card) = 0 := fun x =>
      (Finset.sum_eq_zero_iff_of_nonneg (fun x _ => log_fiber_nonneg f x)).mp hsum x (mem_univ x)
    intro a b hab
    have h1 : (fiber f (f a)).card = 1 := by
      have hpos : (0:ℝ) < ((fiber f (f a)).card : ℝ) := by exact_mod_cast fiber_card_pos f a
      have : ((fiber f (f a)).card : ℝ) = 1 := Real.eq_one_of_pos_of_log_eq_zero hpos (hz a)
      exact_mod_cast this
    exact Finset.card_le_one.mp (le_of_eq h1) a (mem_fiber.mpr rfl) b (mem_fiber.mpr hab.symm)
  · intro hinj
    have hone : ∀ x : α, (fiber f (f x)).card = 1 := by
      intro x
      apply Finset.card_eq_one.mpr ⟨x, ?_⟩
      ext z
      simp only [mem_fiber, Finset.mem_singleton]
      exact ⟨fun h => hinj h, fun h => by rw [h]⟩
    simp [erasedNats, hone]

/-! ## The counting form of Landauer's principle -/

lemma sum_fiber_card (f : α → β) :
    ∑ y ∈ Finset.univ.image f, (fiber f y).card = Fintype.card α := by
  rw [Fintype.card, Finset.card_eq_sum_card_fiberwise (f := f) (t := Finset.univ.image f)
    (fun x _ => Finset.mem_image_of_mem f (mem_univ x))]
  rfl

lemma fiber_card_pos_of_mem_image {f : α → β} {y : β} (hy : y ∈ Finset.univ.image f) :
    0 < (fiber f y).card := by
  obtain ⟨x, _, rfl⟩ := Finset.mem_image.mp hy
  exact Finset.card_pos.mpr ⟨x, mem_fiber.mpr rfl⟩

/-- Per-fiber Gibbs inequality, the analytic heart of the counting bound.  For a fiber of
size `c` inside a source of size `N` mapping onto `M` values,
`c·log N - c·log M ≤ c·log c + N/M - c`; summing over the `M` fibers makes the
correction terms cancel. -/
lemma fiber_term_bound (N M c : ℝ) (hN : 0 < N) (hM : 0 < M) (hc : 0 < c) :
    c * Real.log N - c * Real.log M ≤ c * Real.log c + N / M - c := by
  have ht : (0:ℝ) < N / (c * M) := by positivity
  have h := Real.log_le_sub_one_of_pos ht
  rw [Real.log_div (by positivity) (by positivity), Real.log_mul (ne_of_gt hc) (ne_of_gt hM)] at h
  have hcc : c * (Real.log N - (Real.log c + Real.log M)) ≤ c * (N / (c * M) - 1) :=
    mul_le_mul_of_nonneg_left h (le_of_lt hc)
  have e1 : c * (Real.log N - (Real.log c + Real.log M))
      = c * Real.log N - c * Real.log c - c * Real.log M := by ring
  have e2 : c * (N / (c * M) - 1) = N / M - c := by
    have : c * (N / (c * M)) = N / M := by
      field_simp
    rw [mul_sub, mul_one, this]
  rw [e1, e2] at hcc
  linarith

/-- **Landauer's principle, counting form.**  Any deterministic map erases at least
`log |Src| - log |image|` nats, whatever its fiber-size profile. -/
theorem erasedNats_ge_log_ratio [Nonempty α] (f : α → β) :
    Real.log (Fintype.card α) - Real.log ((Finset.univ.image f).card) ≤ erasedNats f := by
  have hcardpos : (0:ℝ) < (Fintype.card α : ℝ) := by exact_mod_cast Fintype.card_pos (α := α)
  set N : ℝ := (Fintype.card α : ℝ) with hNdef
  set I := Finset.univ.image f with hI
  set M : ℝ := (I.card : ℝ) with hMdef
  have hNpos : 0 < N := hcardpos
  have hIne : I.Nonempty := ⟨f (Classical.arbitrary α), Finset.mem_image_of_mem f (mem_univ _)⟩
  have hMpos : 0 < M := by
    have := Finset.card_pos.mpr hIne
    rw [hMdef]; exact_mod_cast this
  have hsum : ∑ x : α, Real.log ((fiber f (f x)).card)
      = ∑ y ∈ I, ((fiber f y).card : ℝ) * Real.log ((fiber f y).card) := by
    rw [Finset.sum_comp (fun y : β => Real.log ((fiber f y).card)) f]
    refine Finset.sum_congr rfl ?_
    intro y _
    simp [fiber, nsmul_eq_mul]
  have hcards : ∑ y ∈ I, ((fiber f y).card : ℝ) = N := by
    rw [hNdef, ← sum_fiber_card f]
    push_cast
    rfl
  have hkey : N * (Real.log N - Real.log M)
      ≤ ∑ y ∈ I, ((fiber f y).card : ℝ) * Real.log ((fiber f y).card) := by
    have hterm : ∀ y ∈ I, ((fiber f y).card : ℝ) * Real.log N - ((fiber f y).card:ℝ) * Real.log M
        ≤ ((fiber f y).card:ℝ) * Real.log ((fiber f y).card) + N / M - ((fiber f y).card:ℝ) := by
      intro y hy
      have hc : (0:ℝ) < ((fiber f y).card : ℝ) := by
        exact_mod_cast fiber_card_pos_of_mem_image hy
      exact fiber_term_bound N M _ hNpos hMpos hc
    have hsum2 := Finset.sum_le_sum hterm
    have hL : ∑ y ∈ I, (((fiber f y).card : ℝ) * Real.log N - ((fiber f y).card:ℝ) * Real.log M)
        = N * Real.log N - N * Real.log M := by
      rw [Finset.sum_sub_distrib, ← Finset.sum_mul, ← Finset.sum_mul, hcards]
    have hR : ∑ y ∈ I, (((fiber f y).card:ℝ) * Real.log ((fiber f y).card) + N / M
          - ((fiber f y).card:ℝ))
        = (∑ y ∈ I, ((fiber f y).card:ℝ) * Real.log ((fiber f y).card)) + M * (N/M) - N := by
      rw [Finset.sum_sub_distrib, Finset.sum_add_distrib, Finset.sum_const, hcards, hMdef]
      simp [nsmul_eq_mul]
    rw [hL, hR] at hsum2
    have hMN : M * (N/M) = N := by field_simp
    rw [hMN] at hsum2
    linarith
  rw [erasedNats, ← hNdef, le_div_iff₀ hNpos, hsum]
  linarith

/-- Surjective form of the counting bound. -/
theorem erasedNats_ge_log_card_ratio [Nonempty α] [Fintype β] (f : α → β)
    (hf : Function.Surjective f) :
    Real.log (Fintype.card α) - Real.log (Fintype.card β) ≤ erasedNats f := by
  have himg : Finset.univ.image f = (Finset.univ : Finset β) :=
    Finset.eq_univ_of_forall fun y => by
      obtain ⟨x, hx⟩ := hf y
      exact Finset.mem_image.mpr ⟨x, Finset.mem_univ x, hx⟩
  have := erasedNats_ge_log_ratio f
  rwa [himg, Finset.card_univ] at this

/-- Universal upper bound: no map can erase more than the whole entropy of its source. -/
theorem erasedNats_le_log_card (f : α → β) :
    erasedNats f ≤ Real.log (Fintype.card α) := by
  rcases isEmpty_or_nonempty α with hα | hα
  · simp [erasedNats, Fintype.card_eq_zero]
  · have hcardpos : (0:ℝ) < (Fintype.card α : ℝ) := by exact_mod_cast Fintype.card_pos (α := α)
    rw [erasedNats, div_le_iff₀ hcardpos]
    have hterm : ∀ x : α, Real.log ((fiber f (f x)).card) ≤ Real.log (Fintype.card α) := by
      intro x
      apply Real.log_le_log
      · exact_mod_cast fiber_card_pos f x
      · exact_mod_cast Finset.card_le_univ (fiber f (f x))
    calc ∑ x : α, Real.log ((fiber f (f x)).card)
        ≤ ∑ _x : α, Real.log (Fintype.card α) := Finset.sum_le_sum fun x _ => hterm x
      _ = Real.log (Fintype.card α) * Fintype.card α := by
          rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]; ring

/-- **Strict pigeonhole cost.**  Any compression that genuinely shrinks the proof space
dissipates a strictly positive amount of heat at positive temperature. -/
theorem landauerHeat_pos_of_card_lt [Nonempty α] [Fintype β] (f : α → β)
    (kB T : ℝ) (hkB : 0 < kB) (hT : 0 < T) (hcard : Fintype.card β < Fintype.card α) :
    0 < landauerHeat kB T f := by
  have hninj : ¬ Function.Injective f := fun hinj =>
    absurd (Fintype.card_le_of_injective f hinj) (not_le.mpr hcard)
  have hne : erasedNats f ≠ 0 := fun h => hninj ((erasedNats_eq_zero_iff f).mp h)
  have hpos : 0 < erasedNats f := lt_of_le_of_ne (erasedNats_nonneg f) (Ne.symm hne)
  exact mul_pos (mul_pos hkB hT) hpos

/-- **Monotonicity of erasure under further compression**: post-composing can only
destroy more information. -/
theorem erasedNats_mono_comp [DecidableEq γ] (f : α → β) (g : β → γ) :
    erasedNats f ≤ erasedNats (g ∘ f) := by
  have hs : (∑ x : α, Real.log ((fiber f (f x)).card))
      ≤ ∑ x : α, Real.log ((fiber (g ∘ f) ((g ∘ f) x)).card) := by
    refine Finset.sum_le_sum fun x _ => ?_
    apply Real.log_le_log
    · exact_mod_cast fiber_card_pos f x
    · have hsub : fiber f (f x) ⊆ fiber (g ∘ f) ((g ∘ f) x) := by
        intro z hz
        rw [mem_fiber] at hz ⊢
        simp [hz]
      exact_mod_cast Finset.card_le_card hsub
  rcases isEmpty_or_nonempty α with hα | hα
  · haveI := hα
    simp [erasedNats]
  · have hcard : (0:ℝ) < (Fintype.card α : ℝ) := by exact_mod_cast Fintype.card_pos (α := α)
    rw [erasedNats, erasedNats, div_eq_mul_inv, div_eq_mul_inv]
    exact mul_le_mul_of_nonneg_right hs (le_of_lt (inv_pos.mpr hcard))

/-! ## Bennett's reversible implementation -/

/-- **Bennett (1973) for proof compression.**  Every compression `f` can be realised by a
logically reversible map `x ↦ (f x, x)` which outputs the short proof together with the
history; this dissipates *nothing*.  The Landauer cost is therefore a cost of *discarding*
the long proof, not of producing the short one. -/
theorem bennett_reversible_implementation [Nonempty α] [DecidableEq α] (f : α → β) :
    ∃ g : α → β × α, Function.Injective g ∧ (∀ x, (g x).1 = f x) ∧
      erasedNats g = 0 := by
  refine ⟨fun x => (f x, x), ?_, fun _ => rfl, ?_⟩
  · intro a b hab
    exact congrArg Prod.snd hab
  · exact (erasedNats_eq_zero_iff _).mpr (fun a b hab => congrArg Prod.snd hab)

/-! ## Exact erasure of a truncation (prefix) compression -/

/-- Splitting a proof as (kept prefix, discarded suffix), the fiber over a prefix is the
whole set of suffixes. -/
lemma fiber_fst [DecidableEq α] [Fintype γ] (a : α) :
    (fiber (Prod.fst : α × γ → α) a) = ({a} : Finset α) ×ˢ (Finset.univ : Finset γ) := by
  ext ⟨u, v⟩
  simp [fiber, eq_comm]

/-- **Exact cost of truncation.**  Discarding the last block of a proof erases exactly
`log |discarded block|` nats — the tight instance of the Landauer bound. -/
theorem erasedNats_fst [DecidableEq α] [Fintype γ] [Nonempty α] [Nonempty γ] :
    erasedNats (Prod.fst : α × γ → α) = Real.log (Fintype.card γ) := by
  have hfib : ∀ p : α × γ, (fiber (Prod.fst : α × γ → α) p.1).card = Fintype.card γ := by
    intro p
    rw [fiber_fst, Finset.card_product]
    simp
  have hcard : (0:ℝ) < (Fintype.card (α × γ) : ℝ) := by
    exact_mod_cast Fintype.card_pos (α := α × γ)
  rw [erasedNats]
  rw [Finset.sum_congr rfl (fun p _ => by rw [hfib p])]
  rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul]
  field_simp

/-! ## Proof systems, compression instances and the conjecture -/

/-- A *compression instance*: a finite space `Src` of `n`-step proofs of some theorem, a
finite space `Tgt` of `m`-step proofs of the same theorem, and a compression map that
reaches every short proof. -/
structure CompressionInstance where
  /-- length of the long proofs -/
  n : ℕ
  /-- length of the short proofs -/
  m : ℕ
  /-- compression really shortens -/
  hmn : m ≤ n
  /-- the space of `n`-step proofs -/
  Src : Type
  /-- the space of `m`-step proofs -/
  Tgt : Type
  /-- finiteness of the source -/
  fintypeSrc : Fintype Src
  /-- finiteness of the target -/
  fintypeTgt : Fintype Tgt
  /-- there is at least one long proof -/
  nonemptySrc : Nonempty Src
  /-- decidable equality on short proofs -/
  decTgt : DecidableEq Tgt
  /-- the compression procedure -/
  compress : Src → Tgt
  /-- every short proof arises -/
  surj : Function.Surjective compress

/-- Information erased (in nats) by a compression instance. -/
noncomputable def CompressionInstance.erasure (I : CompressionInstance) : ℝ :=
  @erasedNats I.Src I.Tgt I.fintypeSrc I.decTgt I.compress

/-- Heat dissipated by a compression instance at temperature `T`. -/
noncomputable def CompressionInstance.heat (I : CompressionInstance) (kB T : ℝ) : ℝ :=
  kB * T * I.erasure

/-- The conjecture exactly as stated: *independently of the proof system*, compressing an
`n`-step proof to an `m`-step proof erases at least `n - m` bits. -/
def NaiveLandauerProofCompression : Prop :=
  ∀ I : CompressionInstance, ((I.n : ℝ) - I.m) * Real.log 2 ≤ I.erasure

/-- A *rigid* proof system: exactly one proof of each length.  Compressing costs nothing,
because there was nothing to choose in the first place. -/
def rigidInstance (n m : ℕ) (h : m ≤ n) : CompressionInstance where
  n := n
  m := m
  hmn := h
  Src := Unit
  Tgt := Unit
  fintypeSrc := inferInstance
  fintypeTgt := inferInstance
  nonemptySrc := inferInstance
  decTgt := inferInstance
  compress := id
  surj := Function.surjective_id

lemma rigidInstance_erasure (n m : ℕ) (h : m ≤ n) : (rigidInstance n m h).erasure = 0 := by
  show @erasedNats Unit Unit _ _ id = 0
  exact (erasedNats_eq_zero_iff (α := Unit) (β := Unit) id).mpr Function.injective_id

/-- **The conjecture is false as stated.**  The claimed bound `kT(n-m)log 2` is *not*
independent of the proof system: in a rigid system the compression `1000 ↦ 100` is
logically reversible and free.  The number of steps is not an amount of information;
only the *logarithm of the number of proofs* is. -/
theorem naiveLandauerProofCompression_false : ¬ NaiveLandauerProofCompression := by
  intro h
  have hineq := h (rigidInstance 1000 100 (by norm_num))
  rw [rigidInstance_erasure] at hineq
  have hlog : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hpos : (0:ℝ) < (((rigidInstance 1000 100 (by norm_num)).n : ℝ)
      - ((rigidInstance 1000 100 (by norm_num)).m : ℝ)) * Real.log 2 := by
    refine mul_pos ?_ hlog
    show (0:ℝ) < ((1000 : ℕ) : ℝ) - ((100 : ℕ) : ℝ)
    norm_num
  linarith

/-- **The corrected principle.**  If the space of `n`-step proofs is at least `2^(n-m)`
times as large as the space of `m`-step proofs (the *redundancy hypothesis*, which
formalises "each of the erased steps was a genuine binary choice"), then the conjectured
Landauer bound does hold. -/
theorem landauer_compression_bound_of_redundancy (I : CompressionInstance)
    (hred : (2:ℝ) ^ (I.n - I.m) * (@Fintype.card I.Tgt I.fintypeTgt)
      ≤ (@Fintype.card I.Src I.fintypeSrc)) :
    ((I.n - I.m : ℕ) : ℝ) * Real.log 2 ≤ I.erasure := by
  have hbound := @erasedNats_ge_log_card_ratio I.Src I.Tgt I.fintypeSrc I.decTgt
    I.nonemptySrc I.fintypeTgt I.compress I.surj
  have hTgtpos : (0:ℝ) < ((@Fintype.card I.Tgt I.fintypeTgt : ℕ) : ℝ) := by
    have : 0 < @Fintype.card I.Tgt I.fintypeTgt :=
      (@Fintype.card_pos_iff I.Tgt I.fintypeTgt).mpr
        ⟨I.compress (@Classical.arbitrary I.Src I.nonemptySrc)⟩
    exact_mod_cast this
  have hprodpos : (0:ℝ) < (2:ℝ) ^ (I.n - I.m) * ((@Fintype.card I.Tgt I.fintypeTgt : ℕ) : ℝ) := by
    have h2 : (0:ℝ) < (2:ℝ) ^ (I.n - I.m) := by positivity
    exact mul_pos h2 hTgtpos
  have hlog : Real.log ((2:ℝ) ^ (I.n - I.m) * ((@Fintype.card I.Tgt I.fintypeTgt : ℕ) : ℝ))
      ≤ Real.log ((@Fintype.card I.Src I.fintypeSrc : ℕ) : ℝ) :=
    Real.log_le_log hprodpos hred
  rw [Real.log_mul (by positivity) (ne_of_gt hTgtpos), Real.log_pow] at hlog
  have hfinal : ((I.n - I.m : ℕ) : ℝ) * Real.log 2
      ≤ Real.log ((@Fintype.card I.Src I.fintypeSrc : ℕ) : ℝ)
        - Real.log ((@Fintype.card I.Tgt I.fintypeTgt : ℕ) : ℝ) := by
    linarith
  exact hfinal.trans hbound

/-! ## Full binary proof spaces: the bound is exactly tight -/

/-- The full binary proof space of length `n`, split as (first `m` steps, last `n-m`
steps): every sequence of binary rule choices is a proof. -/
def binarySrc (n m : ℕ) : Type := Fin (2 ^ m) × Fin (2 ^ (n - m))

instance (n m : ℕ) : Fintype (binarySrc n m) := instFintypeProd _ _
instance (n m : ℕ) : DecidableEq (binarySrc n m) := instDecidableEqProd
instance (n m : ℕ) : Nonempty (binarySrc n m) :=
  ⟨(⟨0, by positivity⟩, ⟨0, by positivity⟩)⟩

/-- The truncation compression on full binary proof spaces. -/
def binaryTruncate (n m : ℕ) : binarySrc n m → Fin (2 ^ m) := Prod.fst

theorem binaryTruncate_surjective (n m : ℕ) : Function.Surjective (binaryTruncate n m) := by
  intro a
  exact ⟨(a, ⟨0, by positivity⟩), rfl⟩

/-- Truncating a full binary `n`-step proof to its first `m` steps erases exactly
`(n-m) log 2` nats, i.e. exactly `n - m` bits. -/
theorem binaryTruncate_erasure (n m : ℕ) :
    erasedNats (binaryTruncate n m) = ((n - m : ℕ) : ℝ) * Real.log 2 := by
  have h := erasedNats_fst (α := Fin (2 ^ m)) (γ := Fin (2 ^ (n - m)))
  rw [binaryTruncate]
  rw [show (Prod.fst : binarySrc n m → Fin (2^m)) = (Prod.fst : Fin (2^m) × Fin (2^(n-m)) → Fin (2^m)) from rfl]
  rw [h, Fintype.card_fin]
  rw [show ((2 ^ (n - m) : ℕ) : ℝ) = (2:ℝ) ^ (n - m) by push_cast; ring, Real.log_pow]

/-- **Tightness.**  Over a full binary proof space, `(n-m)·log 2` is *exactly* the least
erasure achievable by any surjective compression to the `m`-step proofs: the counting
bound is attained by truncation. -/
theorem binary_landauer_bound_isLeast (n m : ℕ) :
    IsLeast {r : ℝ | ∃ f : binarySrc n m → Fin (2 ^ m),
        Function.Surjective f ∧ erasedNats f = r} (((n - m : ℕ) : ℝ) * Real.log 2) := by
  constructor
  · exact ⟨binaryTruncate n m, binaryTruncate_surjective n m, binaryTruncate_erasure n m⟩
  · rintro r ⟨f, hsurj, rfl⟩
    have hb := erasedNats_ge_log_card_ratio f hsurj
    have hcard : Fintype.card (binarySrc n m) = 2 ^ m * 2 ^ (n - m) := by
      rw [show Fintype.card (binarySrc n m)
            = Fintype.card (Fin (2 ^ m) × Fin (2 ^ (n - m))) from rfl,
        Fintype.card_prod, Fintype.card_fin, Fintype.card_fin]
    rw [hcard, Fintype.card_fin] at hb
    have hrw : Real.log ((2 ^ m * 2 ^ (n - m) : ℕ) : ℝ) - Real.log ((2 ^ m : ℕ) : ℝ)
        = ((n - m : ℕ) : ℝ) * Real.log 2 := by
      have h1 : ((2 ^ m * 2 ^ (n - m) : ℕ) : ℝ) = (2:ℝ) ^ m * (2:ℝ) ^ (n - m) := by push_cast; ring
      have h2 : ((2 ^ m : ℕ) : ℝ) = (2:ℝ) ^ m := by push_cast; ring
      rw [h1, h2, Real.log_mul (by positivity) (by positivity), Real.log_pow, Real.log_pow]
      ring
    rw [hrw] at hb
    exact hb

/-! ## The branching factor: proof length is not information -/

/-- Proof space with branching factor `b ≥ 1`, split into kept and discarded blocks. -/
def branchSrc (b n m : ℕ) : Type := Fin (b ^ m) × Fin (b ^ (n - m))

instance (b n m : ℕ) : Fintype (branchSrc b n m) := instFintypeProd _ _

instance branchSrc_nonempty (b n m : ℕ) [NeZero b] : Nonempty (branchSrc b n m) :=
  ⟨(⟨0, Nat.pow_pos (Nat.pos_of_ne_zero (NeZero.ne b))⟩,
    ⟨0, Nat.pow_pos (Nat.pos_of_ne_zero (NeZero.ne b))⟩)⟩

/-- **The true cost of one erased proof step is `log b`, not `log 2`.**  With branching
factor `b`, truncating an `n`-step proof to `m` steps erases exactly `(n-m)·log b`. -/
theorem branching_erasure_eq (b n m : ℕ) (hb : 0 < b) :
    erasedNats (Prod.fst : branchSrc b n m → Fin (b ^ m))
      = ((n - m : ℕ) : ℝ) * Real.log b := by
  haveI : NeZero b := ⟨by omega⟩
  haveI : Nonempty (Fin (b ^ m)) := ⟨⟨0, Nat.pow_pos hb⟩⟩
  haveI : Nonempty (Fin (b ^ (n - m))) := ⟨⟨0, Nat.pow_pos hb⟩⟩
  have h := erasedNats_fst (α := Fin (b ^ m)) (γ := Fin (b ^ (n - m)))
  rw [show (Prod.fst : branchSrc b n m → Fin (b^m))
      = (Prod.fst : Fin (b^m) × Fin (b^(n-m)) → Fin (b^m)) from rfl, h, Fintype.card_fin]
  rw [show ((b ^ (n - m) : ℕ) : ℝ) = (b:ℝ) ^ (n - m) by push_cast; ring, Real.log_pow]

/-- For branching factor `b ≥ 3` the conjectured bound is a strict *under*estimate: the
number of steps erased does not determine the heat, the entropy per step does. -/
theorem branching_beats_naive_bound (b n m : ℕ) (hb : 3 ≤ b) (hmn : m < n) :
    ((n - m : ℕ) : ℝ) * Real.log 2
      < erasedNats (Prod.fst : branchSrc b n m → Fin (b ^ m)) := by
  have hb0 : 0 < b := by omega
  rw [branching_erasure_eq b n m hb0]
  have hstep : Real.log 2 < Real.log b := by
    apply Real.log_lt_log (by norm_num)
    have : (3:ℝ) ≤ (b:ℝ) := by exact_mod_cast hb
    linarith
  have hpos : (0:ℝ) < ((n - m : ℕ) : ℝ) := by
    have : 0 < n - m := by omega
    exact_mod_cast this
  exact (mul_lt_mul_of_pos_left hstep hpos)

/-! ## The requested numeric instance: 1000 steps ↦ 100 steps -/

/-- Boltzmann's constant in J/K (exact, SI 2019). -/
noncomputable def boltzmann : ℝ := 1380649 / 10 ^ 29

/-- Room temperature in kelvin. -/
def roomT : ℝ := 300

/-- The heat dissipated when a full-binary 1000-step proof (e.g. of the fundamental
theorem of algebra) is irreversibly compressed to a 100-step proof at room temperature. -/
noncomputable def ftaCompressionHeat : ℝ :=
  landauerHeat boltzmann roomT (binaryTruncate 1000 100)

/-- The compression `1000 ↦ 100` steps costs exactly `900 kB T log 2`. -/
theorem fta_compression_heat_eq :
    ftaCompressionHeat = boltzmann * roomT * (900 : ℝ) * Real.log 2 := by
  rw [ftaCompressionHeat, landauerHeat, binaryTruncate_erasure]
  norm_num
  ring

/-- Numerical value: about `2.5838 × 10⁻¹⁸` joules. -/
theorem fta_compression_heat_bracket :
    25838 / 10 ^ 22 < ftaCompressionHeat ∧ ftaCompressionHeat < 25839 / 10 ^ 22 := by
  rw [fta_compression_heat_eq, boltzmann, roomT]
  constructor
  · nlinarith [Real.log_two_gt_d9]
  · nlinarith [Real.log_two_lt_d9]

/-- Equivalently: exactly `900` bits are erased. -/
theorem fta_compression_bits : erasedBits (binaryTruncate 1000 100) = 900 := by
  rw [erasedBits, binaryTruncate_erasure]
  have h2 : Real.log 2 ≠ 0 := ne_of_gt (Real.log_pos (by norm_num))
  field_simp
  norm_num

end LandauerProofCompression