import Mathlib
import Bridges.ORDialCap

/-!
# OR-DIAL-MAXIMUM: a global cap for the semiprime OR channel

Fix a finite abelian group `G` (the intended example is `G = (ℤ/m)ˣ`, the classes of
primes modulo `m`).  A **class-rate profile** is a map `r : G → [0,1]`, where `r(c)` is
the probability that a "fork event" `E(p)` happens for a prime `p` in class `c`.  For a
semiprime `N = p q` with `p, q` independent and uniform over `G`, the OR channel is

`N mod m  ↦  [E(p) OR E(q)]`.

Writing `s = 1 - r` for the no-fork profile, the counting identity over unit pairs
`ab ≡ N` gives the conditional no-fork probability

`f(c) = (1/|G|) Σ_a s(a) s(c a⁻¹)`  (`noFork s c` below),

and the channel's mutual information is `Φ(s) = H(μ²) - avg_c H(f(c))` (`orInfo`),
with `μ = avg s`, all entropies in nats.

## Main results

* `noFork_le`, `noFork_ge`, `avg_noFork`: the *window law*.  For every profile the
  conditional no-fork probabilities satisfy `max(0, 2μ-1) ≤ f(c) ≤ μ` and have mean
  exactly `μ²`.  This is the structural input to the variational principle.
* `orInfo_le_orCap`: **the global cap.**  For *every* class-rate profile on *every*
  finite abelian group, `Φ ≤ orCap = H(3/4) - ½H(1/2) = 0.31128… bits`.
* `orInfo_subgroupProfile`: **the subgroup law.**  For the kernel profile of a subgroup
  of index `n`, `Φ = H(1/n²) - (1/n) H(1/n)` exactly (paper 72's order-`n` law, and the
  AND-companion law).
* `orInfo_index_two_eq_orCap` and `orDial_isGreatest`: the cap is *attained*, exactly by
  the index-two (quadratic character) kernels, so the maximum is a genuine maximum.
* `xor_determined_by_product`: for an index-two kernel, the XOR event is a deterministic
  function of `N` alone — raw mutual information there is `1` bit and is factor-useless.
-/

open Real Finset

namespace ORDial

variable {G : Type*} [Fintype G] [CommGroup G]

/-! ## Averages over the class group -/

/-- The average of `F` over the (finite, nonempty) class group. -/
noncomputable def avg (F : G → ℝ) : ℝ := (∑ a : G, F a) / (Fintype.card G)

lemma card_pos' : 0 < (Fintype.card G : ℝ) := by exact_mod_cast Fintype.card_pos

@[simp] lemma avg_const (k : ℝ) : avg (fun _ : G => k) = k := by
  simp [avg, Finset.sum_const]

lemma avg_affine (α β : ℝ) (F : G → ℝ) : avg (fun c => α + β * F c) = α + β * avg F := by
  have h := card_pos' (G := G)
  simp only [avg, Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_const, nsmul_eq_mul,
    Finset.card_univ]
  field_simp

omit [CommGroup G] in
lemma avg_add (F H : G → ℝ) : avg (fun a => F a + H a) = avg F + avg H := by
  unfold avg; rw [Finset.sum_add_distrib]; ring

omit [CommGroup G] in
lemma avg_mono {F H : G → ℝ} (h : ∀ c, F c ≤ H c) : avg F ≤ avg H := by
  have hs : ∑ a : G, F a ≤ ∑ a : G, H a := Finset.sum_le_sum (fun i _ => h i)
  unfold avg; gcongr

/-- Averaging is invariant under the translation `a ↦ c a⁻¹`. -/
lemma avg_translate (F : G → ℝ) (c : G) : avg (fun a => F (c * a⁻¹)) = avg F := by
  unfold avg; congr 1
  exact Fintype.sum_equiv ((Equiv.inv G).trans (Equiv.mulLeft c)) _ _ (fun a => rfl)

/-! ## The semiprime OR channel -/

/-- `noFork s c` is the probability that *neither* prime factor forks, conditional on the
semiprime lying in class `c`: `f(c) = (1/|G|) Σ_a s(a) s(c a⁻¹)`. -/
noncomputable def noFork (s : G → ℝ) (c : G) : ℝ := avg (fun a => s a * s (c * a⁻¹))

/-- The mutual information `I(N mod m ; [E(p) OR E(q)])` of the semiprime OR channel
attached to the no-fork profile `s = 1 - r`, in nats. -/
noncomputable def orInfo (s : G → ℝ) : ℝ :=
  Real.binEntropy ((avg s)^2) - avg (fun c => Real.binEntropy (noFork s c))

variable {s : G → ℝ}

lemma avg_nonneg (hs0 : ∀ a, 0 ≤ s a) : 0 ≤ avg s := by
  have := avg_mono (F := fun _ : G => (0:ℝ)) (H := s) hs0
  rwa [avg_const] at this

lemma avg_le_one (hs1 : ∀ a, s a ≤ 1) : avg s ≤ 1 := by
  have := avg_mono (F := s) (H := fun _ : G => (1:ℝ)) hs1
  rwa [avg_const] at this

lemma noFork_nonneg (hs0 : ∀ a, 0 ≤ s a) (c : G) : 0 ≤ noFork s c := by
  have : avg (fun _ : G => (0:ℝ)) ≤ avg (fun a => s a * s (c * a⁻¹)) :=
    avg_mono (fun a => mul_nonneg (hs0 a) (hs0 _))
  rwa [avg_const] at this

/-- **Upper window.** The conditional no-fork probability never exceeds the mean rate. -/
lemma noFork_le (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1) (c : G) : noFork s c ≤ avg s :=
  avg_mono (fun a => by nlinarith [hs0 a, hs1 (c * a⁻¹), hs0 (c * a⁻¹)])

/-- **Lower window.** From `xy ≥ x + y - 1` on `[0,1]²`. -/
lemma noFork_ge (hs1 : ∀ a, s a ≤ 1) (c : G) :
    2 * avg s - 1 ≤ noFork s c := by
  have h1 : avg (fun a => s a + s (c * a⁻¹) - 1) ≤ noFork s c :=
    avg_mono (fun a => by nlinarith [hs1 a, hs1 (c*a⁻¹)])
  have h2 : avg (fun a => s a + s (c * a⁻¹) - 1) = 2 * avg s - 1 := by
    have he : (fun a : G => s a + s (c * a⁻¹) - 1) = fun a => (-1) + 1 * (s a + s (c * a⁻¹)) := by
      funext a; ring
    rw [he, avg_affine, avg_add, avg_translate]; ring
  linarith

/-- **Mean law.** The conditional no-fork probabilities average to `μ²`. -/
lemma avg_noFork (s : G → ℝ) : avg (noFork s) = (avg s)^2 := by
  have hn : (0:ℝ) < Fintype.card G := card_pos' (G := G)
  have key : ∑ c : G, ∑ a : G, s a * s (c * a⁻¹) = (∑ a : G, s a) * (∑ b : G, s b) := by
    rw [Finset.sum_comm, Finset.sum_mul]
    refine Finset.sum_congr rfl fun a _ => ?_
    rw [← Finset.mul_sum]
    congr 1
    exact Equiv.sum_comp (Equiv.mulRight a⁻¹) s
  unfold avg noFork avg
  rw [← Finset.sum_div, key]
  field_simp

/-! ## The variational principle -/

/-- If the mean no-fork rate is `0`, the OR event is certain and the channel is silent. -/
lemma orInfo_of_mean_zero (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1) (h : avg s = 0) :
    orInfo s = 0 := by
  have hf : ∀ c : G, noFork s c = 0 := fun c =>
    le_antisymm (by have := noFork_le hs0 hs1 c; rwa [h] at this) (noFork_nonneg hs0 c)
  unfold orInfo
  simp only [hf, h]
  norm_num

/-- If the mean no-fork rate is `1`, the OR event is impossible and the channel is silent. -/
lemma orInfo_of_mean_one (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1) (h : avg s = 1) :
    orInfo s = 0 := by
  have hf : ∀ c : G, noFork s c = 1 := fun c =>
    le_antisymm (by have := noFork_le hs0 hs1 c; rwa [h] at this)
      (by have := noFork_ge hs1 c; rw [h] at this; linarith)
  unfold orInfo
  simp only [hf, h]
  norm_num

/-- Chord bound in the low regime `μ ≤ 1/2`, where the window is `[0, μ]`. -/
lemma orInfo_le_left (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1) (hpos : 0 < avg s)
    (hhalf : avg s ≤ 1/2) :
    orInfo s ≤ Real.binEntropy ((avg s)^2) - avg s * Real.binEntropy (avg s) := by
  set m : ℝ := avg s with hm
  have hm1 : m ≤ 1 := by linarith
  have hchord : ∀ c : G, 0 + (Real.binEntropy m / m) * noFork s c
      ≤ Real.binEntropy (noFork s c) := by
    intro c
    have h := binEntropy_chord (L := 0) (U := m) (x := noFork s c) le_rfl hm1 hpos
      (noFork_nonneg hs0 c) (by rw [hm]; exact noFork_le hs0 hs1 c)
    simp only [Real.binEntropy_zero, sub_zero, mul_zero, zero_add] at h
    calc 0 + Real.binEntropy m / m * noFork s c
        = (noFork s c * Real.binEntropy m) / m := by field_simp; ring
      _ ≤ Real.binEntropy (noFork s c) := h
  have havg : m * Real.binEntropy m ≤ avg (fun c => Real.binEntropy (noFork s c)) := by
    have h1 : avg (fun c => 0 + (Real.binEntropy m / m) * noFork s c)
        ≤ avg (fun c => Real.binEntropy (noFork s c)) := avg_mono hchord
    rwa [avg_affine, avg_noFork, ← hm, show (Real.binEntropy m / m) * m^2 = m * Real.binEntropy m
      by field_simp, zero_add] at h1
  unfold orInfo
  linarith

/-- Chord bound in the high regime `μ ≥ 1/2`, where the window is `[2μ-1, μ]`. -/
lemma orInfo_le_right (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1) (hhalf : 1/2 ≤ avg s)
    (hlt : avg s < 1) :
    orInfo s ≤ Real.binEntropy ((avg s)^2)
      - (avg s * Real.binEntropy (2 * avg s - 1) + (1 - avg s) * Real.binEntropy (avg s)) := by
  set m : ℝ := avg s with hm
  have hm1 : m ≤ 1 := by linarith
  have hL0 : 0 ≤ 2*m - 1 := by linarith
  have hLU : 2*m - 1 < m := by linarith
  have h1m : (1:ℝ) - m ≠ 0 := by linarith
  set bL := Real.binEntropy (2*m-1) with hbL
  set bU := Real.binEntropy m with hbU
  have hchord : ∀ c : G, ((m * bL - (2*m-1) * bU)/(1-m))
      + ((bU - bL)/(1-m)) * noFork s c ≤ Real.binEntropy (noFork s c) := by
    intro c
    have h := binEntropy_chord (L := 2*m-1) (U := m) (x := noFork s c) hL0 hm1 hLU
      (by rw [hm]; exact noFork_ge hs1 c) (by rw [hm]; exact noFork_le hs0 hs1 c)
    have hne : m - (2*m-1) = 1 - m := by ring
    rw [hne] at h
    calc (m * bL - (2*m-1) * bU)/(1-m) + ((bU - bL)/(1-m)) * noFork s c
        = ((m - noFork s c) * bL + (noFork s c - (2*m-1)) * bU) / (1-m) := by
          field_simp; ring
      _ ≤ Real.binEntropy (noFork s c) := h
  have havg : m * bL + (1-m) * bU ≤ avg (fun c => Real.binEntropy (noFork s c)) := by
    have h1 := avg_mono hchord
    rw [avg_affine, avg_noFork, ← hm] at h1
    have hid : (m * bL - (2*m-1) * bU)/(1-m) + ((bU - bL)/(1-m)) * m^2
        = m * bL + (1-m) * bU := by
      field_simp; ring
    rwa [hid] at h1
  unfold orInfo
  linarith

/-- **OR-DIAL-MAXIMUM.**  For every class-rate profile on every finite abelian class
group, the mutual information of the semiprime OR channel is at most
`orCap = H(3/4) - ½H(1/2)`.

The proof combines the window law (`noFork_le`, `noFork_ge`), the mean law
(`avg_noFork`), concavity of the binary entropy (`binEntropy_chord`), and the two sharp
one-dimensional estimates `left_branch` / `right_branch`. -/
theorem orInfo_le_orCap (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1) : orInfo s ≤ orCap := by
  have hm0 : 0 ≤ avg s := avg_nonneg hs0
  have hm1 : avg s ≤ 1 := avg_le_one hs1
  rcases eq_or_lt_of_le hm0 with hzero | hpos
  · rw [orInfo_of_mean_zero hs0 hs1 hzero.symm]; linarith [orCap_gt]
  rcases eq_or_lt_of_le hm1 with hone | hlt
  · rw [orInfo_of_mean_one hs0 hs1 hone]; linarith [orCap_gt]
  rcases le_or_gt (avg s) (1/2) with hcase | hcase
  · exact le_trans (orInfo_le_left hs0 hs1 hpos hcase) (left_branch _ hpos hcase)
  · exact le_trans (orInfo_le_right hs0 hs1 hcase.le hlt) (right_branch _ hcase.le hlt)

/-- **Rigidity.**  The cap is reached only at mean no-fork rate `μ = 1/2`, i.e. only when
the OR event has unconditional probability `3/4`.  Every other profile is strictly below
the cap. -/
theorem orInfo_lt_orCap_of_mean_ne_half (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1)
    (hne : avg s ≠ 1/2) : orInfo s < orCap := by
  have hm0 : 0 ≤ avg s := avg_nonneg hs0
  have hm1 : avg s ≤ 1 := avg_le_one hs1
  rcases eq_or_lt_of_le hm0 with hzero | hpos
  · rw [orInfo_of_mean_zero hs0 hs1 hzero.symm]; linarith [orCap_gt]
  rcases eq_or_lt_of_le hm1 with hone | hlt
  · rw [orInfo_of_mean_one hs0 hs1 hone]; linarith [orCap_gt]
  rcases lt_or_gt_of_ne hne with hcase | hcase
  · exact lt_of_le_of_lt (orInfo_le_left hs0 hs1 hpos hcase.le) (left_branch_strict _ hpos hcase)
  · exact lt_of_le_of_lt (orInfo_le_right hs0 hs1 hcase.le hlt)
      (right_branch_strict _ hcase hlt)

/-- Consequently a maximising profile must have mean no-fork rate exactly `1/2`. -/
theorem mean_eq_half_of_orInfo_eq_orCap (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1)
    (heq : orInfo s = orCap) : avg s = 1/2 := by
  by_contra hne
  exact absurd heq (ne_of_lt (orInfo_lt_orCap_of_mean_ne_half hs0 hs1 hne))


/-! ## The subgroup (character kernel) profiles, and attainment -/

open Classical in
/-- The kernel profile of a subgroup `K`: no-fork exactly on `K`.  For `K` of index `n`
this is the "order-`n` character event" profile. -/
noncomputable def subgroupProfile (K : Subgroup G) : G → ℝ := fun a => if a ∈ K then 1 else 0

omit [Fintype G] in
lemma subgroupProfile_nonneg (K : Subgroup G) (a : G) : 0 ≤ subgroupProfile K a := by
  unfold subgroupProfile; split <;> norm_num

omit [Fintype G] in
lemma subgroupProfile_le_one (K : Subgroup G) (a : G) : subgroupProfile K a ≤ 1 := by
  unfold subgroupProfile; split <;> norm_num

/-- The mean of a kernel profile is the reciprocal of the index. -/
lemma avg_subgroupProfile (K : Subgroup G) : avg (subgroupProfile K) = 1 / (K.index : ℝ) := by
  classical
  have hcard : (Nat.card K) * K.index = Fintype.card G := by
    rw [Subgroup.card_mul_index, Nat.card_eq_fintype_card]
  have hsum : ∑ a : G, subgroupProfile K a = (Nat.card K : ℝ) := by
    unfold subgroupProfile
    rw [Finset.sum_boole]
    rw [Nat.card_eq_fintype_card, Fintype.card_subtype]
  have hidx : (0:ℝ) < (K.index : ℝ) := by
    have : 0 < K.index := Nat.pos_of_ne_zero Subgroup.index_ne_zero_of_finite
    exact_mod_cast this
  have hc : (0:ℝ) < Fintype.card G := card_pos' (G := G)
  unfold avg
  rw [hsum]
  rw [← hcard]
  push_cast
  rw [mul_comm]
  field_simp

/-- Conditional no-fork probabilities of a kernel profile: `1/n` on the subgroup, `0` off it. -/
lemma noFork_subgroupProfile (K : Subgroup G) (c : G) :
    noFork (subgroupProfile K) c = subgroupProfile K c * avg (subgroupProfile K) := by
  classical
  unfold noFork
  by_cases hc : c ∈ K
  · have hfun : (fun a : G => subgroupProfile K a * subgroupProfile K (c * a⁻¹))
        = fun a => 0 + 1 * subgroupProfile K a := by
      funext a
      unfold subgroupProfile
      by_cases ha : a ∈ K
      · simp [ha, K.mul_mem hc (K.inv_mem ha)]
      · simp [ha]
    rw [hfun, avg_affine]
    unfold subgroupProfile
    simp [hc]
  · have hfun : (fun a : G => subgroupProfile K a * subgroupProfile K (c * a⁻¹))
        = fun _ : G => (0:ℝ) := by
      funext a
      unfold subgroupProfile
      by_cases ha : a ∈ K
      · have : c * a⁻¹ ∉ K := by
          intro hmem
          exact hc (by simpa using K.mul_mem hmem ha)
        simp [ha, this]
      · simp [ha]
    rw [hfun, avg_const]
    unfold subgroupProfile
    simp [hc]

/-- **The subgroup law** (paper 72's order-`n` law, and the AND-companion law).  For the
kernel profile of a subgroup of index `n`,

`Φ = H(1/n²) - (1/n) H(1/n)`  exactly. -/
theorem orInfo_subgroupProfile (K : Subgroup G) :
    orInfo (subgroupProfile K)
      = Real.binEntropy ((1 / (K.index:ℝ))^2)
        - (1 / (K.index:ℝ)) * Real.binEntropy (1 / (K.index:ℝ)) := by
  classical
  have hmean := avg_subgroupProfile K
  have hpt : ∀ c : G, Real.binEntropy (noFork (subgroupProfile K) c)
      = 0 + (Real.binEntropy (avg (subgroupProfile K))) * subgroupProfile K c := by
    intro c
    rw [noFork_subgroupProfile]
    unfold subgroupProfile
    by_cases hc : c ∈ K <;> simp [hc]
  unfold orInfo
  rw [hmean]
  have : avg (fun c => Real.binEntropy (noFork (subgroupProfile K) c))
      = (1 / (K.index:ℝ)) * Real.binEntropy (1 / (K.index:ℝ)) := by
    simp only [hpt, hmean]
    rw [avg_affine, hmean]
    ring
  rw [this]

/-- **Attainment.**  An index-two (quadratic character) kernel realises the cap exactly. -/
theorem orInfo_index_two_eq_orCap (K : Subgroup G) (h : K.index = 2) :
    orInfo (subgroupProfile K) = orCap := by
  have hhalf : Real.binEntropy ((1:ℝ)/2) = Real.log 2 := by
    rw [show (1:ℝ)/2 = 2⁻¹ by norm_num]; exact Real.binEntropy_two_inv
  rw [orInfo_subgroupProfile, h]
  norm_num
  rw [hhalf, orCap]
  ring

/-- The OR dial has a genuine **global maximum** on any class group carrying a quadratic
character (an index-two subgroup): the value is `orCap`. -/
theorem orDial_isGreatest (K : Subgroup G) (h : K.index = 2) :
    IsGreatest {x : ℝ | ∃ s : G → ℝ, (∀ a, 0 ≤ s a ∧ s a ≤ 1) ∧ orInfo s = x} orCap := by
  constructor
  · exact ⟨subgroupProfile K,
      fun a => ⟨subgroupProfile_nonneg K a, subgroupProfile_le_one K a⟩,
      orInfo_index_two_eq_orCap K h⟩
  · rintro x ⟨s, hs, rfl⟩
    exact orInfo_le_orCap (fun a => (hs a).1) (fun a => (hs a).2)

/-- The AND-companion law `Φ_AND(n) = H(1/n²) - (1/n)H(1/n)` is itself capped by `g(2)`,
for every `n ≥ 2` — a statement about real numbers, independent of any group. -/
theorem andLaw_le_orCap (n : ℕ) (hn : 2 ≤ n) :
    Real.binEntropy ((1/(n:ℝ))^2) - (1/(n:ℝ)) * Real.binEntropy (1/(n:ℝ)) ≤ orCap := by
  have hn0 : (0:ℝ) < n := by positivity
  have h2 : (2:ℝ) ≤ n := by exact_mod_cast hn
  exact left_branch (1/(n:ℝ)) (by positivity) (by rw [div_le_div_iff₀ hn0 (by norm_num)]; linarith)

/-! ## Rate form: the OR channel and its AND companion

The paper states the dial in terms of the *fork rate* `r`, with
`P(OR | N ≡ c) = 1 - (1/φ) Σ_a (1-r(a))(1-r(ca⁻¹))`.  We record that form here and show
that the OR channel of `r` is the channel of the no-fork profile `1 - r`, that the AND
channel of `r` is the channel of `r` itself, and hence that both are capped by `g(2)`. -/

/-- `P(OR | N ≡ c)`, the conditional probability that at least one factor forks. -/
noncomputable def forkOr (r : G → ℝ) (c : G) : ℝ := 1 - noFork (fun a => 1 - r a) c

/-- `P(AND | N ≡ c)`, the conditional probability that both factors fork. -/
noncomputable def forkAnd (r : G → ℝ) (c : G) : ℝ := noFork r c

/-- `I(N mod m ; OR)` written directly with the OR probabilities. -/
noncomputable def orInfoRate (r : G → ℝ) : ℝ :=
  Real.binEntropy (avg (forkOr r)) - avg (fun c => Real.binEntropy (forkOr r c))

/-- `I(N mod m ; AND)` written directly with the AND probabilities. -/
noncomputable def andInfoRate (r : G → ℝ) : ℝ :=
  Real.binEntropy (avg (forkAnd r)) - avg (fun c => Real.binEntropy (forkAnd r c))

/-- The unconditional OR probability is `1 - μ²` with `μ = avg (1-r)`. -/
lemma avg_forkOr (r : G → ℝ) : avg (forkOr r) = 1 - (avg (fun a => 1 - r a))^2 := by
  have h : (fun c => forkOr r c) = fun c => 1 + (-1) * noFork (fun a => 1 - r a) c := by
    funext c; unfold forkOr; ring
  rw [show avg (forkOr r) = avg (fun c => forkOr r c) from rfl, h, avg_affine, avg_noFork]
  ring

/-- The OR channel of a rate profile is the channel of the complementary no-fork profile. -/
theorem orInfoRate_eq_orInfo (r : G → ℝ) : orInfoRate r = orInfo (fun a => 1 - r a) := by
  unfold orInfoRate orInfo
  rw [avg_forkOr]
  have h1 : Real.binEntropy (1 - (avg (fun a => 1 - r a))^2)
      = Real.binEntropy ((avg (fun a => 1 - r a))^2) := Real.binEntropy_one_sub _
  have h2 : ∀ c : G, Real.binEntropy (forkOr r c)
      = Real.binEntropy (noFork (fun a => 1 - r a) c) := by
    intro c; unfold forkOr; exact Real.binEntropy_one_sub _
  rw [h1]
  simp only [h2]

/-- The AND channel of a rate profile is literally the channel of that profile. -/
theorem andInfoRate_eq_orInfo (r : G → ℝ) : andInfoRate r = orInfo r := by
  unfold andInfoRate orInfo forkAnd
  rw [avg_noFork]

/-- **AND/OR duality.**  The AND channel of `r` is the OR channel of `1 - r`. -/
theorem andInfoRate_eq_orInfoRate_one_sub (r : G → ℝ) :
    andInfoRate r = orInfoRate (fun a => 1 - r a) := by
  rw [andInfoRate_eq_orInfo, orInfoRate_eq_orInfo]
  simp

/-- The cap in rate form: no fork-rate profile pushes the OR channel past `g(2)`. -/
theorem orInfoRate_le_orCap {r : G → ℝ} (hr0 : ∀ a, 0 ≤ r a) (hr1 : ∀ a, r a ≤ 1) :
    orInfoRate r ≤ orCap := by
  rw [orInfoRate_eq_orInfo]
  exact orInfo_le_orCap (fun a => by linarith [hr1 a]) (fun a => by linarith [hr0 a])

/-- The AND channel obeys the same cap. -/
theorem andInfoRate_le_orCap {r : G → ℝ} (hr0 : ∀ a, 0 ≤ r a) (hr1 : ∀ a, r a ≤ 1) :
    andInfoRate r ≤ orCap := by
  rw [andInfoRate_eq_orInfo]
  exact orInfo_le_orCap hr0 hr1

/-- At the maximiser the OR event has unconditional probability exactly `3/4`. -/
theorem orMarginal_eq_three_quarters (K : Subgroup G) (h : K.index = 2) :
    avg (forkOr (fun a => 1 - subgroupProfile K a)) = 3/4 := by
  have hs : (fun a : G => 1 - (1 - subgroupProfile K a)) = subgroupProfile K := by
    funext a; ring
  rw [avg_forkOr, hs, avg_subgroupProfile, h]
  norm_num

/-- A nonnegative function with vanishing average vanishes identically. -/
lemma eq_zero_of_avg_eq_zero {F : G → ℝ} (hF : ∀ c, 0 ≤ F c) (h : avg F = 0) (c : G) :
    F c = 0 := by
  have hn : (0:ℝ) < Fintype.card G := card_pos' (G := G)
  have hsum : ∑ a : G, F a = 0 := by
    have := h
    unfold avg at this
    field_simp at this
    simpa using this
  exact (Finset.sum_eq_zero_iff_of_nonneg (fun i _ => hF i)).mp hsum c (Finset.mem_univ c)

/-- **Second rigidity theorem.**  A maximising profile is *two-valued*: conditional on the
semiprime class, the no-fork probability is either `0` or `1/2` — equivalently the OR event
has conditional probability `1` or `1/2`.  This is exactly the profile shape produced by a
quadratic character kernel. -/
theorem noFork_eq_zero_or_half_of_max (hs0 : ∀ a, 0 ≤ s a) (hs1 : ∀ a, s a ≤ 1)
    (heq : orInfo s = orCap) (c : G) : noFork s c = 0 ∨ noFork s c = 1/2 := by
  have hhalf : avg s = 1/2 := mean_eq_half_of_orInfo_eq_orCap hs0 hs1 heq
  -- the chord through `(0, 0)` and `(1/2, log 2)`
  have hchord : ∀ d : G, 2 * Real.log 2 * noFork s d ≤ Real.binEntropy (noFork s d) := by
    intro d
    have hx0 : 0 ≤ noFork s d := noFork_nonneg hs0 d
    have hx1 : noFork s d ≤ 1/2 := by have := noFork_le hs0 hs1 d; rwa [hhalf] at this
    have h := binEntropy_chord (L := 0) (U := 1/2) (x := noFork s d) le_rfl (by norm_num)
      (by norm_num) hx0 hx1
    rw [Real.binEntropy_zero, binEntropy_half] at h
    calc 2 * Real.log 2 * noFork s d
        = ((1/2 - noFork s d) * 0 + (noFork s d - 0) * Real.log 2) / (1/2 - 0) := by
          field_simp; ring
      _ ≤ Real.binEntropy (noFork s d) := h
  -- the average of the entropies is exactly the chord value, so the gap vanishes pointwise
  have havgH : avg (fun d => Real.binEntropy (noFork s d)) = Real.log 2 / 2 := by
    have h1 : Real.binEntropy ((avg s)^2) = Real.binEntropy (1/4) := by
      rw [hhalf]; norm_num
    have := heq
    unfold orInfo at this
    rw [h1, orCap] at this
    linarith
  have havgC : avg (fun d => 2 * Real.log 2 * noFork s d) = Real.log 2 / 2 := by
    have : avg (fun d => 0 + (2 * Real.log 2) * noFork s d) = 0 + (2 * Real.log 2) * (avg s)^2 := by
      rw [avg_affine, avg_noFork]
    simp only [zero_add] at this
    rw [this, hhalf]
    ring
  have hgap : avg (fun d => Real.binEntropy (noFork s d) - 2 * Real.log 2 * noFork s d) = 0 := by
    have hsplit : (fun d : G => Real.binEntropy (noFork s d) - 2 * Real.log 2 * noFork s d)
        = fun d => Real.binEntropy (noFork s d) + (-1) * (2 * Real.log 2 * noFork s d) := by
      funext d; ring
    rw [hsplit]
    have := avg_add (fun d : G => Real.binEntropy (noFork s d))
      (fun d : G => (-1) * (2 * Real.log 2 * noFork s d))
    rw [this]
    have h2 : avg (fun d : G => (-1) * (2 * Real.log 2 * noFork s d))
        = (-1) * avg (fun d : G => 2 * Real.log 2 * noFork s d) := by
      have := avg_affine (0:ℝ) (-1) (fun d : G => 2 * Real.log 2 * noFork s d)
      simpa using this
    rw [h2, havgH, havgC]
    ring
  have hzero := eq_zero_of_avg_eq_zero (F := fun d => Real.binEntropy (noFork s d)
      - 2 * Real.log 2 * noFork s d) (fun d => by linarith [hchord d]) hgap c
  -- strict concavity rules out interior values
  by_contra hcon
  push_neg at hcon
  obtain ⟨hne0, hnehalf⟩ := hcon
  have hx0 : 0 < noFork s c := lt_of_le_of_ne (noFork_nonneg hs0 c) (Ne.symm hne0)
  have hx1 : noFork s c < 1/2 :=
    lt_of_le_of_ne (by have := noFork_le hs0 hs1 c; rwa [hhalf] at this) hnehalf
  have ha : 0 < 1 - 2 * noFork s c := by linarith
  have hb : 0 < 2 * noFork s c := by linarith
  have hab : (1 - 2 * noFork s c) + 2 * noFork s c = 1 := by ring
  have hstrict := Real.strictConcave_binEntropy.2 (by norm_num : (0:ℝ) ∈ Set.Icc (0:ℝ) 1)
    (by norm_num : (1/2:ℝ) ∈ Set.Icc (0:ℝ) 1) (by norm_num) ha hb hab
  simp only [smul_eq_mul, Real.binEntropy_zero, mul_zero, zero_add] at hstrict
  rw [binEntropy_half] at hstrict
  have hpt : 2 * noFork s c * (1/2) = noFork s c := by ring
  rw [hpt] at hstrict
  linarith

/-! ## Factor-uselessness: the XOR of a quadratic kernel is a function of `N` -/

omit [Fintype G] in
/-- For an index-two kernel, the XOR event `E(p) XOR E(q)` is *determined by the product*
`N = pq` alone: it happens exactly when `N ∉ K`.  Hence its mutual information with
`N mod m` is a full bit, and carries no information about the factorisation. -/
theorem xor_determined_by_product (K : Subgroup G) (h : K.index = 2) (p q : G) :
    (Xor' (p ∈ K) (q ∈ K)) ↔ p * q ∉ K := by
  obtain ⟨a, ha⟩ := Subgroup.index_eq_two_iff.mp h
  have hane : a ∉ K := by
    have h1 := ha 1
    rw [one_mul] at h1
    rcases h1 with ⟨h1, h2⟩ | ⟨_, h2⟩
    · exact absurd K.one_mem h2
    · exact h2
  have haa : a * a ∈ K := by
    rcases ha a with ⟨h1, _⟩ | ⟨h1, _⟩
    · exact h1
    · exact absurd h1 hane
  constructor
  · rintro (⟨hp, hq⟩ | ⟨hp, hq⟩)
    · intro hmem
      exact hq (by simpa using K.mul_mem (K.inv_mem hp) hmem)
    · intro hmem
      exact hq (by simpa [mul_comm] using K.mul_mem hmem (K.inv_mem hp))
  · intro hmem
    by_cases hp : p ∈ K
    · left
      refine ⟨hp, fun hq => hmem (K.mul_mem hp hq)⟩
    · right
      refine ⟨?_, hp⟩
      by_contra hq
      -- both `p` and `q` are outside `K`, hence `pa, qa ∈ K` and `pq = (pa)(qa)(aa)⁻¹ ∈ K`
      have hpa : p * a ∈ K := by
        rcases ha p with ⟨h1, _⟩ | ⟨h1, _⟩
        · exact h1
        · exact absurd h1 hp
      have hqa : q * a ∈ K := by
        rcases ha q with ⟨h1, _⟩ | ⟨h1, _⟩
        · exact h1
        · exact absurd h1 hq
      have : p * q ∈ K := by
        have := K.mul_mem (K.mul_mem hpa hqa) (K.inv_mem haa)
        have heq : (p * a) * (q * a) * (a * a)⁻¹ = p * q := by
          simp [mul_inv_rev, mul_comm, mul_assoc, mul_left_comm]
        rwa [heq] at this
      exact hmem this

end ORDial