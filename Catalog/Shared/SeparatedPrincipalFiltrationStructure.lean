/-
# The structure of the intersection ideal `⨅ n, (aⁿ)`

Cycle 2 of the investigation.  Instead of asking *when* the intersection vanishes, we
describe the intersection itself.  Over a domain the ideal

  `J = ⨅ n, (aⁿ)`

is characterised purely order-theoretically: it is the **greatest** `a`-divisible ideal,
i.e. the greatest fixed point of the monotone map `I ↦ (a) * I` on the lattice of ideals.
Separation is then exactly the statement that this greatest fixed point is trivial, and
the classical chain-condition proofs become instances of Nakayama's lemma applied to that
fixed point.

Main results:

* `iInf_filt_eq_mul` — `J = (a) * J` in any domain (`a`-divisibility of the intersection);
* `isGreatest_iInf_filt` — `J` is the greatest ideal `I` with `I ≤ (a) * I`;
* `isSeparated_of_isNoetherian_nakayama` — a self-contained Nakayama proof of the
  principal Krull intersection theorem, independent of the multiplicity-based proof;
* `ord_le_of_height` — the `a`-adic order is the pointwise *minimal* height function,
  so the two criteria of the core file are related by a universal property.
-/
import Mathlib
import Shared.SeparatedPrincipalFiltration
import Shared.SeparatedPrincipalFiltrationValuation

namespace SeparatedPrincipalFiltration

variable {R : Type*} [CommRing R]

/-! ## The intersection is the greatest `a`-divisible ideal -/

/-- In a domain every element of `⨅ n, (aⁿ)` is `a` times another element of the
intersection: the intersection is `a`-divisible. -/
theorem iInf_filt_le_mul [IsDomain R] (a : R) :
    (⨅ n, filt a n) ≤ Ideal.span {a} * (⨅ n, filt a n) := by
  intro x hx
  rw [mem_iInf_filt_iff] at hx
  rcases eq_or_ne a 0 with rfl | ha
  · have hx0 : x = 0 := by simpa using hx 1
    simp [hx0]
  obtain ⟨y, hy⟩ := hx 1
  have hy' : y ∈ ⨅ n, filt a n := by
    rw [mem_iInf_filt_iff]
    intro n
    obtain ⟨c, hc⟩ := hx (n + 1)
    refine ⟨c, ?_⟩
    apply mul_left_cancel₀ ha
    calc a * y = x := by rw [hy, pow_one]
      _ = a * (a ^ n * c) := by rw [hc]; ring
  have : a * y ∈ Ideal.span {a} * (⨅ n, filt a n) :=
    Ideal.mul_mem_mul (Ideal.mem_span_singleton_self a) hy'
  rw [pow_one] at hy
  rwa [← hy] at this

/-- Any ideal that is `a`-divisible is contained in `⨅ n, (aⁿ)`; no hypothesis on `R`
is needed for this half. -/
theorem le_iInf_filt_of_le_mul {a : R} {I : Ideal R} (hI : I ≤ Ideal.span {a} * I) :
    I ≤ ⨅ n, filt a n := by
  have key : ∀ n : ℕ, I ≤ filt a n := by
    intro n
    induction n with
    | zero => simp [filt]
    | succ n ih =>
        refine hI.trans ?_
        calc Ideal.span {a} * I ≤ Ideal.span {a} * filt a n := Ideal.mul_mono_right ih
          _ = filt a (n + 1) := by
              rw [filt, filt, Ideal.span_singleton_mul_span_singleton, ← pow_succ']
  exact le_iInf key

/-- **`J = (a)·J`.**  Over a domain the intersection of the principal filtration is a
fixed point of `I ↦ (a) * I`. -/
theorem iInf_filt_eq_mul [IsDomain R] (a : R) :
    (⨅ n, filt a n) = Ideal.span {a} * (⨅ n, filt a n) :=
  le_antisymm (iInf_filt_le_mul a) Ideal.mul_le_left

/-- **Greatest fixed point.**  Over a domain, `⨅ n, (aⁿ)` is the greatest `a`-divisible
ideal.  Separation therefore says exactly that `I ↦ (a)*I` has no nonzero fixed point. -/
theorem isGreatest_iInf_filt [IsDomain R] (a : R) :
    IsGreatest {I : Ideal R | I ≤ Ideal.span {a} * I} (⨅ n, filt a n) :=
  ⟨iInf_filt_le_mul a, fun _ hI => le_iInf_filt_of_le_mul hI⟩

/-- Separation, reformulated as the absence of nonzero `a`-divisible ideals. -/
theorem isSeparated_iff_no_divisible_ideal [IsDomain R] {a : R} :
    IsSeparated a ↔ ∀ I : Ideal R, I ≤ Ideal.span {a} * I → I = ⊥ := by
  constructor
  · intro h I hI
    exact le_bot_iff.mp (h ▸ le_iInf_filt_of_le_mul hI)
  · intro h
    exact h _ (iInf_filt_le_mul a)

/-! ## A Nakayama proof of the principal Krull intersection theorem

This is a second, structurally different proof of `isSeparated_of_not_isUnit` in the
Noetherian case: rather than counting multiplicities we apply Nakayama's lemma to the
fixed point `J = (a)·J`. -/

theorem isSeparated_of_isNoetherian_nakayama [IsDomain R] [IsNoetherianRing R] {a : R}
    (ha : ¬ IsUnit a) : IsSeparated a := by
  set J : Ideal R := ⨅ n, filt a n with hJ
  have hfg : J.FG := (IsNoetherian.noetherian J)
  have hle : J ≤ Ideal.span {a} • J := by
    rw [smul_eq_mul]
    exact iInf_filt_le_mul a
  obtain ⟨r, hr, hzero⟩ :=
    Submodule.exists_sub_one_mem_and_smul_eq_zero_of_fg_of_le_smul (Ideal.span {a}) J hfg hle
  obtain ⟨t, ht⟩ := Ideal.mem_span_singleton.mp hr
  have hr0 : r ≠ 0 := by
    rintro rfl
    exact ha (isUnit_iff_exists_inv.mpr ⟨-t, by linear_combination ht⟩)
  refine isSeparated_iff.mpr fun x hx => ?_
  have hxJ : x ∈ J := mem_iInf_filt_iff.mpr hx
  have := hzero x hxJ
  rw [smul_eq_mul] at this
  exact (mul_eq_zero.mp this).resolve_left hr0

/-! ## Universality of the `a`-adic order among height functions -/

/-- **Minimality of the `a`-adic order.**  Every height function witnessing separation
at `a` dominates the `a`-adic order pointwise.  Thus `ord a` is the canonical, smallest
witness of the height criterion. -/
theorem ord_le_of_height [IsDomain R] {a : R} (ha : a ≠ 0) (h : IsSeparated a)
    (v : R → ℕ) (hv : ∀ x : R, x ≠ 0 → v x < v (a * x)) {x : R} (hx : x ≠ 0) :
    ord a x ≤ v x := by
  obtain ⟨c, hc⟩ := pow_ord_dvd h hx
  have hc0 : c ≠ 0 := by
    rintro rfl
    exact hx (by simpa using hc)
  have := le_height_pow_mul ha v hv (ord a x) c hc0
  rw [← hc] at this
  omega

/-- The `a`-adic order really is attained: it is itself a height function. -/
theorem ord_is_height [IsDomain R] {a : R} (ha : a ≠ 0) (h : IsSeparated a) {x : R}
    (hx : x ≠ 0) : ord a x < ord a (a * x) := by
  have hfin : FiniteMultiplicity a x := finite_of_isSeparated h hx
  have hfin' : FiniteMultiplicity a (a * x) := finite_of_isSeparated h (mul_ne_zero ha hx)
  have := multiplicity_mul_self ha hfin hfin'
  simp only [ord]
  omega

end SeparatedPrincipalFiltration