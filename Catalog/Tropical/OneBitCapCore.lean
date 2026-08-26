/-
# The one-bit cap, I: generic fibre estimates for the counting channel

This file develops the two-sided *fibre sandwich* for the counting entropy of
`CyclicTypeChannel`, the symmetry of the counting mutual information, and the
resulting two-sided envelope for the semiprime type-pair channel

  `Ipair n  =  log₂ n  -  H(N mod f | type pair)`.

The point of the reformulation is that `H(N mod f | type pair)` is an average of
entropies of *sum maps on product sets*, and a sum map on a product set `A × B`
has all its fibres of size at most `min (#A) (#B)`.  This gives the universal
upper bound

  `Ipair n ≤ log₂ n - avg_{(a,b)} log₂ (max (φ (T a)) (φ (T b)))`,

which is the engine of the odd-order half of the even/odd dichotomy, and — when
the fibre bound is an equality, which happens exactly for the two-state fork
`q = 2` — of the even half as well.

Everything here is proved from the definitions of `uEnt`, `condEnt`, `mutInfo`
in `Shared.CyclicTypeChannel`; no new axioms and no `native_decide`.
-/
import Shared.CyclicTypeChannelCRTLaw
import Shared.CyclicTypeChannelNonneg
import Shared.CyclicTypeChannelPrime

namespace CyclicTypeChannel

open Finset

variable {α β γ : Type*}

/-! ## 1. The fibre sandwich for the counting entropy -/

section Sandwich

variable [DecidableEq β] {s : Finset α} {g : α → β}

/-- **Fibre sandwich, upper half.**  If every fibre of `g` on `s` has at most `M`
elements then the entropy is at least `log₂ (#s / M)`. -/
theorem uEnt_ge_of_fiber_card_le {M : ℕ} (hM : 0 < M)
    (h : ∀ a ∈ s, #{x ∈ s | g x = g a} ≤ M) :
    Real.logb 2 s.card - Real.logb 2 M ≤ uEnt s g := by
  classical
  rcases s.eq_empty_or_nonempty with rfl | hs
  · have : (0 : ℝ) ≤ Real.logb 2 M := Real.logb_nonneg (by norm_num) (by exact_mod_cast hM)
    simp only [uEnt, card_empty, Nat.cast_zero, Real.logb_zero, sum_empty, zero_div, sub_zero]
    linarith
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  have hterm : ∀ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ) ≤ Real.logb 2 M := by
    intro a ha
    have h1 : (0 : ℝ) < (#{x ∈ s | g x = g a} : ℝ) := by exact_mod_cast fiber_card_pos ha
    exact Real.logb_le_logb_of_le (by norm_num) h1 (by exact_mod_cast h a ha)
  have hsum : (∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ))
      ≤ (s.card : ℝ) * Real.logb 2 M := by
    calc (∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ))
        ≤ ∑ _a ∈ s, Real.logb 2 (M : ℝ) := Finset.sum_le_sum hterm
      _ = (s.card : ℝ) * Real.logb 2 M := by simp [Finset.sum_const, nsmul_eq_mul]
  have : (∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ)) / s.card ≤ Real.logb 2 M := by
    rw [div_le_iff₀ hN]; linarith
  simp only [uEnt]
  linarith

/-- **Fibre sandwich, lower half.**  If every fibre of `g` on `s` has at least `m`
elements then the entropy is at most `log₂ (#s / m)`. -/
theorem uEnt_le_of_fiber_card_ge {m : ℕ} (hm : 0 < m) (hs : s.Nonempty)
    (h : ∀ a ∈ s, m ≤ #{x ∈ s | g x = g a}) :
    uEnt s g ≤ Real.logb 2 s.card - Real.logb 2 m := by
  classical
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  have hterm : ∀ a ∈ s, Real.logb 2 (m : ℝ) ≤ Real.logb 2 (#{x ∈ s | g x = g a} : ℝ) := by
    intro a ha
    have h1 : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
    exact Real.logb_le_logb_of_le (by norm_num) h1 (by exact_mod_cast h a ha)
  have hsum : (s.card : ℝ) * Real.logb 2 m
      ≤ ∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ) := by
    calc (s.card : ℝ) * Real.logb 2 m = ∑ _a ∈ s, Real.logb 2 (m : ℝ) := by
          simp [Finset.sum_const, nsmul_eq_mul]
      _ ≤ _ := Finset.sum_le_sum hterm
  have : Real.logb 2 m ≤ (∑ a ∈ s, Real.logb 2 (#{x ∈ s | g x = g a} : ℝ)) / s.card := by
    rw [le_div_iff₀ hN]; linarith
  simp only [uEnt]
  linarith

/-- **Entropy is capped by the log of the size of any set containing the range.**
This is Gibbs' inequality against the uniform distribution on `S`. -/
theorem uEnt_le_logb_card_of_mapsTo {S : Finset β} (hS : 0 < S.card)
    (h : ∀ x ∈ s, g x ∈ S) :
    uEnt s g ≤ Real.logb 2 S.card := by
  classical
  have hK : (0 : ℝ) < (S.card : ℝ) := by exact_mod_cast hS
  have hlogK : (0 : ℝ) ≤ Real.logb 2 S.card :=
    Real.logb_nonneg (by norm_num) (by exact_mod_cast hS)
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simpa [uEnt] using hlogK
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have himg : s.image g ⊆ S := by
    intro v hv
    obtain ⟨x, hx, rfl⟩ := Finset.mem_image.1 hv
    exact h x hx
  have hcard : ((s.image g).card : ℝ) ≤ (S.card : ℝ) := by
    exact_mod_cast Finset.card_le_card himg
  set P : β → ℝ := fun v => (#{x ∈ s | g x = v} : ℝ) / s.card with hP
  have hPpos : ∀ v ∈ s.image g, 0 < P v := by
    intro v hv
    obtain ⟨x, hx, rfl⟩ := Finset.mem_image.1 hv
    have : (0 : ℝ) < (#{y ∈ s | g y = g x} : ℝ) := by exact_mod_cast fiber_card_pos hx
    exact div_pos this hN
  have hsum1 : ∑ v ∈ s.image g, P v = 1 := by
    have : ∑ v ∈ s.image g, (#{x ∈ s | g x = v} : ℝ) = (s.card : ℝ) := by
      exact_mod_cast congrArg (Nat.cast (R := ℝ)) (sum_fiber_card s g)
    rw [hP]
    simp only
    rw [← Finset.sum_div, this, div_self (ne_of_gt hN)]
  have hterm : ∀ v ∈ s.image g,
      (P v - 1 / (S.card : ℝ)) / Real.log 2
        ≤ P v * Real.logb 2 (P v) + P v * Real.logb 2 (S.card : ℝ) := by
    intro v hv
    have hpv := hPpos v hv
    have hg := gibbs_term (q := P v) (p := 1 / (S.card : ℝ)) hpv.le (by positivity)
      (fun _ => by positivity)
    have hrw : P v / (1 / (S.card : ℝ)) = P v * (S.card : ℝ) := by
      field_simp
    rw [hrw, Real.logb_mul (ne_of_gt hpv) (ne_of_gt hK), mul_add] at hg
    exact hg
  have hsumterm := Finset.sum_le_sum hterm
  have hleft : ∑ v ∈ s.image g, (P v - 1 / (S.card : ℝ)) / Real.log 2
      = (1 - ((s.image g).card : ℝ) / (S.card : ℝ)) / Real.log 2 := by
    rw [← Finset.sum_div, Finset.sum_sub_distrib, hsum1, Finset.sum_const, nsmul_eq_mul]
    field_simp
  have hleft0 : (0 : ℝ) ≤ ∑ v ∈ s.image g, (P v - 1 / (S.card : ℝ)) / Real.log 2 := by
    rw [hleft]
    have h1 : ((s.image g).card : ℝ) / (S.card : ℝ) ≤ 1 := by
      rw [div_le_one hK]; exact hcard
    exact div_nonneg (by linarith) hlog2.le
  have hright : ∑ v ∈ s.image g, (P v * Real.logb 2 (P v) + P v * Real.logb 2 (S.card : ℝ))
      = (∑ v ∈ s.image g, P v * Real.logb 2 (P v)) + Real.logb 2 (S.card : ℝ) := by
    rw [Finset.sum_add_distrib, ← Finset.sum_mul, hsum1, one_mul]
  have hshannon : uEnt s g = -∑ v ∈ s.image g, P v * Real.logb 2 (P v) := by
    rw [uEnt_eq_shannon hs g, ← Finset.sum_neg_distrib]
    exact Finset.sum_congr rfl fun v _ => by rw [hP]; ring
  rw [hshannon]
  linarith [hsumterm, hleft0, hright]

end Sandwich

/-! ## 2. Symmetry of the counting mutual information -/

section Comm

variable [DecidableEq β] [DecidableEq γ]

/-- **The counting mutual information is symmetric**: `I(g ; k) = I(k ; g)`.
Both sides are the same Kullback–Leibler double sum over the joint count array. -/
theorem mutInfo_comm (s : Finset α) (g : α → β) (k : α → γ) :
    mutInfo s g k = mutInfo s k g := by
  classical
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [mutInfo, uEnt, condEnt]
  rw [mutInfo_eq_double s g k hs, mutInfo_eq_double s k g hs, Finset.sum_comm]
  refine Finset.sum_congr rfl fun v _ => Finset.sum_congr rfl fun c _ => ?_
  have hfil : {x ∈ s | k x = c ∧ g x = v} = {x ∈ s | g x = v ∧ k x = c} :=
    Finset.filter_congr fun x _ => by tauto
  rw [hfil]
  ring

end Comm

/-! ## 3. Class-wise estimates for the conditional entropy -/

section ClassWise

variable [DecidableEq β] [DecidableEq γ]

/-- If a real-valued function `ψ` of the class of `x` is a lower bound for the
entropy of `k` on each class, then its average is a lower bound for the
conditional entropy `H(k | g)`. -/
theorem condEnt_ge_of_class_bound {s : Finset α} {g : α → β} {k : α → γ} {ψ : β → ℝ}
    (h : ∀ x ∈ s, ψ (g x) ≤ uEnt {y ∈ s | g y = g x} k) :
    (∑ x ∈ s, ψ (g x)) / s.card ≤ condEnt s k g := by
  classical
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [condEnt]
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  have hsplit : (∑ x ∈ s, ψ (g x))
      = ∑ v ∈ s.image g, (#{x ∈ s | g x = v} : ℝ) * ψ v := by
    rw [Finset.sum_comp ψ g]
    exact Finset.sum_congr rfl fun v _ => by rw [nsmul_eq_mul]
  rw [hsplit, condEnt, Finset.sum_div]
  refine Finset.sum_le_sum fun v hv => ?_
  obtain ⟨x, hx, rfl⟩ := Finset.mem_image.1 hv
  have hw : (0 : ℝ) ≤ (#{y ∈ s | g y = g x} : ℝ) / s.card := by positivity
  have := mul_le_mul_of_nonneg_left (h x hx) hw
  calc (#{y ∈ s | g y = g x} : ℝ) * ψ (g x) / s.card
      = ((#{y ∈ s | g y = g x} : ℝ) / s.card) * ψ (g x) := by ring
    _ ≤ ((#{y ∈ s | g y = g x} : ℝ) / s.card) * uEnt {y ∈ s | g y = g x} k := this

/-- The dual class-wise estimate: an upper bound on each class entropy averages to
an upper bound on the conditional entropy. -/
theorem condEnt_le_of_class_bound {s : Finset α} {g : α → β} {k : α → γ} {ψ : β → ℝ}
    (h : ∀ x ∈ s, uEnt {y ∈ s | g y = g x} k ≤ ψ (g x)) :
    condEnt s k g ≤ (∑ x ∈ s, ψ (g x)) / s.card := by
  classical
  rcases s.eq_empty_or_nonempty with rfl | hs
  · simp [condEnt]
  have hN : (0 : ℝ) < s.card := by exact_mod_cast card_pos.2 hs
  have hsplit : (∑ x ∈ s, ψ (g x))
      = ∑ v ∈ s.image g, (#{x ∈ s | g x = v} : ℝ) * ψ v := by
    rw [Finset.sum_comp ψ g]
    exact Finset.sum_congr rfl fun v _ => by rw [nsmul_eq_mul]
  rw [hsplit, condEnt, Finset.sum_div]
  refine Finset.sum_le_sum fun v hv => ?_
  obtain ⟨x, hx, rfl⟩ := Finset.mem_image.1 hv
  have hw : (0 : ℝ) ≤ (#{y ∈ s | g y = g x} : ℝ) / s.card := by positivity
  have := mul_le_mul_of_nonneg_left (h x hx) hw
  calc ((#{y ∈ s | g y = g x} : ℝ) / s.card) * uEnt {y ∈ s | g y = g x} k
      ≤ ((#{y ∈ s | g y = g x} : ℝ) / s.card) * ψ (g x) := this
    _ = (#{y ∈ s | g y = g x} : ℝ) * ψ (g x) / s.card := by ring

end ClassWise

/-! ## 4. The residue of the semiprime is uniform -/

lemma card_box' (n : ℕ) : ((box n).card : ℝ) = (n : ℝ) ^ 2 := by
  rw [card_box]; push_cast; ring

/-- **The product residue is uniformly distributed**: `H(N mod f) = log₂ n`. -/
theorem uEnt_box_prodRes {n : ℕ} (hn : 0 < n) :
    uEnt (box n) (prodRes n) = Real.logb 2 n := by
  classical
  have hfib : ∀ x ∈ box n, #{y ∈ box n | prodRes n y = prodRes n x} = n := fun x _ =>
    card_prodRes_fiber hn (Nat.mod_lt _ hn)
  have hn' : (0 : ℝ) < n := by exact_mod_cast hn
  have hsum : (∑ x ∈ box n, Real.logb 2 (#{y ∈ box n | prodRes n y = prodRes n x} : ℝ))
      = ((n : ℝ) ^ 2) * Real.logb 2 n := by
    rw [Finset.sum_congr rfl fun x hx => by rw [hfib x hx]]
    rw [Finset.sum_const, nsmul_eq_mul, card_box']
  rw [uEnt, hsum, card_box']
  have h2 : Real.logb 2 ((n : ℝ) ^ 2) = 2 * Real.logb 2 n := by
    rw [show ((n : ℝ) ^ 2) = (n : ℝ) * (n : ℝ) by ring,
      Real.logb_mul (ne_of_gt hn') (ne_of_gt hn')]
    ring
  rw [h2]
  field_simp
  ring

/-! ## 5. The channel as `log₂ n` minus a conditional entropy -/

/-- The type-pair channel, rewritten with the residue as the *first* variable.
This is the form in which the fibre sandwich applies. -/
theorem Ipair_eq_logb_sub_condEnt {n : ℕ} (hn : 0 < n) :
    Ipair n = Real.logb 2 n - condEnt (box n) (prodRes n) (ordPair n) := by
  rw [Ipair_eq_IpairOrd, IpairOrd, mutInfo_comm, mutInfo, uEnt_box_prodRes hn]

/-! ## 6. Type classes are product sets, and sums on product sets have small
fibres -/

/-- The class of the *ordered* type pair is the product of the two type classes. -/
theorem ordPair_class_eq_product (n : ℕ) (x : ℕ × ℕ) :
    {y ∈ box n | ordPair n y = ordPair n x}
      = ({a ∈ range n | ordType n a = ordType n x.1})
          ×ˢ ({b ∈ range n | ordType n b = ordType n x.2}) := by
  ext y
  simp only [Finset.mem_filter, mem_box_iff, Finset.mem_product, Finset.mem_range,
    ordPair, Prod.mk.injEq]
  tauto

/-- The cardinality of a type class: `φ` of the type. -/
theorem card_type_class {n : ℕ} (hn : 0 < n) (a : ℕ) :
    #{c ∈ range n | ordType n c = ordType n a} = Nat.totient (ordType n a) :=
  card_ordType_eq_totient hn (ordType_dvd a)

/-- Cancellation of a common summand modulo `n`. -/
lemma eq_of_add_mod_eq {n t u v : ℕ} (hu : u < n) (hv : v < n)
    (h : (t + u) % n = (t + v) % n) : u = v := by
  have h1 : u ≡ v [MOD n] := Nat.ModEq.add_left_cancel' t h
  have h2 : u % n = v % n := h1
  rwa [Nat.mod_eq_of_lt hu, Nat.mod_eq_of_lt hv] at h2

/-- **Sums on a product set have small fibres.**  In `A ×ˢ B ⊆ box n`, the fibre of
the sum-residue map over any value injects into `A` and into `B`. -/
theorem card_sum_fiber_le {n : ℕ} (A B : Finset ℕ)
    (hA : A ⊆ range n) (hB : B ⊆ range n) (c : ℕ) :
    #{y ∈ A ×ˢ B | prodRes n y = c} ≤ min A.card B.card := by
  classical
  have hfst : #{y ∈ A ×ˢ B | prodRes n y = c} ≤ A.card := by
    refine Finset.card_le_card_of_injOn Prod.fst
      (fun y hy => (Finset.mem_product.1 (Finset.mem_filter.1 hy).1).1) ?_
    intro y hy z hz h
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_product] at hy hz
    have hy2 : y.2 < n := Finset.mem_range.1 (hB hy.1.2)
    have hz2 : z.2 < n := Finset.mem_range.1 (hB hz.1.2)
    have hmod : (y.1 + y.2) % n = (y.1 + z.2) % n := by
      have e1 : prodRes n y = c := hy.2
      have e2 : prodRes n z = c := hz.2
      simp only [prodRes] at e1 e2
      rw [e1, h]
      exact e2.symm
    exact Prod.ext h (eq_of_add_mod_eq hy2 hz2 hmod)
  have hsnd : #{y ∈ A ×ˢ B | prodRes n y = c} ≤ B.card := by
    refine Finset.card_le_card_of_injOn Prod.snd
      (fun y hy => (Finset.mem_product.1 (Finset.mem_filter.1 hy).1).2) ?_
    intro y hy z hz h
    simp only [Finset.coe_filter, Set.mem_setOf_eq, Finset.mem_product] at hy hz
    have hy1 : y.1 < n := Finset.mem_range.1 (hA hy.1.1)
    have hz1 : z.1 < n := Finset.mem_range.1 (hA hz.1.1)
    have hmod : (y.2 + y.1) % n = (y.2 + z.1) % n := by
      have e1 : prodRes n y = c := hy.2
      have e2 : prodRes n z = c := hz.2
      simp only [prodRes] at e1 e2
      rw [Nat.add_comm y.2 y.1, e1, h, Nat.add_comm z.2 z.1]
      exact e2.symm
    exact Prod.ext (eq_of_add_mod_eq hy1 hz1 hmod) h
  exact le_min hfst hsnd

/-! ## 7. The two-sided class-wise envelope for the channel -/

/-- **Upper envelope.**  Any class-wise lower bound `ψ` for the entropy of the
product residue gives an upper bound for the channel. -/
theorem Ipair_le_avg {n : ℕ} (hn : 0 < n) (ψ : ℕ × ℕ → ℝ)
    (h : ∀ x ∈ box n, ψ (ordPair n x)
      ≤ uEnt {y ∈ box n | ordPair n y = ordPair n x} (prodRes n)) :
    Ipair n ≤ Real.logb 2 n - (∑ x ∈ box n, ψ (ordPair n x)) / ((n : ℝ) ^ 2) := by
  have hc := condEnt_ge_of_class_bound (s := box n) (g := ordPair n) (k := prodRes n) (ψ := ψ) h
  rw [card_box'] at hc
  rw [Ipair_eq_logb_sub_condEnt hn]
  linarith

/-- **Lower envelope.**  Any class-wise upper bound `ψ` for the entropy of the
product residue gives a lower bound for the channel. -/
theorem Ipair_ge_avg {n : ℕ} (hn : 0 < n) (ψ : ℕ × ℕ → ℝ)
    (h : ∀ x ∈ box n, uEnt {y ∈ box n | ordPair n y = ordPair n x} (prodRes n)
      ≤ ψ (ordPair n x)) :
    Real.logb 2 n - (∑ x ∈ box n, ψ (ordPair n x)) / ((n : ℝ) ^ 2) ≤ Ipair n := by
  have hc := condEnt_le_of_class_bound (s := box n) (g := ordPair n) (k := prodRes n) (ψ := ψ) h
  rw [card_box'] at hc
  rw [Ipair_eq_logb_sub_condEnt hn]
  linarith

/-- The class-wise entropy of the product residue is at least the log of the
*larger* of the two type-class sizes. -/
theorem uEnt_class_ge {n : ℕ} (hn : 0 < n) (x : ℕ × ℕ) :
    Real.logb 2 (max (Nat.totient (ordType n x.1)) (Nat.totient (ordType n x.2)) : ℝ)
      ≤ uEnt {y ∈ box n | ordPair n y = ordPair n x} (prodRes n) := by
  classical
  set A := {a ∈ range n | ordType n a = ordType n x.1} with hA
  set B := {b ∈ range n | ordType n b = ordType n x.2} with hB
  have hcA : A.card = Nat.totient (ordType n x.1) := card_type_class hn x.1
  have hcB : B.card = Nat.totient (ordType n x.2) := card_type_class hn x.2
  have hpA : 0 < A.card := by
    rw [hcA]; exact Nat.totient_pos.2 (ordType_pos hn x.1)
  have hpB : 0 < B.card := by
    rw [hcB]; exact Nat.totient_pos.2 (ordType_pos hn x.2)
  have hclass : {y ∈ box n | ordPair n y = ordPair n x} = A ×ˢ B := ordPair_class_eq_product n x
  have hsubA : A ⊆ range n := Finset.filter_subset _ _
  have hsubB : B ⊆ range n := Finset.filter_subset _ _
  have hfib : ∀ y ∈ A ×ˢ B,
      #{z ∈ A ×ˢ B | prodRes n z = prodRes n y} ≤ min A.card B.card := fun y _ =>
    card_sum_fiber_le A B hsubA hsubB _
  have hmin : 0 < min A.card B.card := lt_min hpA hpB
  have hkey := uEnt_ge_of_fiber_card_le (s := A ×ˢ B) (g := prodRes n) hmin hfib
  rw [hclass]
  refine le_trans (le_of_eq ?_) hkey
  have hmulN : (min A.card B.card) * (max A.card B.card) = (A ×ˢ B).card := by
    rw [Finset.card_product]
    rcases le_total A.card B.card with hle | hle
    · rw [min_eq_left hle, max_eq_right hle]
    · rw [min_eq_right hle, max_eq_left hle]; ring
  have hcard : ((A ×ˢ B).card : ℝ)
      = ((min A.card B.card : ℕ) : ℝ) * ((max A.card B.card : ℕ) : ℝ) := by
    exact_mod_cast congrArg (Nat.cast (R := ℝ)) hmulN.symm
  have hminR : (0 : ℝ) < ((min A.card B.card : ℕ) : ℝ) := by exact_mod_cast hmin
  have hmaxR : (0 : ℝ) < ((max A.card B.card : ℕ) : ℝ) := by
    exact_mod_cast lt_max_of_lt_left hpA
  have hmaxN : max A.card B.card
      = max (Nat.totient (ordType n x.1)) (Nat.totient (ordType n x.2)) := by
    rw [hcA, hcB]
  rw [hcard, Real.logb_mul (ne_of_gt hminR) (ne_of_gt hmaxR), hmaxN]
  push_cast
  ring

/-- **The universal upper envelope of the type-pair channel.**

For every cyclic order `n`,
`Ipair n ≤ log₂ n - avg_{(a,b)} log₂ (max (φ (T a)) (φ (T b)))`.

The average is over the whole box of exponent pairs; `φ (T a)` is the number of
exponents sharing the splitting type of `a`.  This single inequality drives the
entire odd half of the even/odd dichotomy, and it is an *equality* for the
two-state fork `n = 2 ^ k`. -/
theorem Ipair_le_maxTotient {n : ℕ} (hn : 0 < n) :
    Ipair n ≤ Real.logb 2 n
      - (∑ x ∈ box n,
          Real.logb 2 (max (Nat.totient (ordType n x.1)) (Nat.totient (ordType n x.2)) : ℝ))
        / ((n : ℝ) ^ 2) :=
  Ipair_le_avg hn
    (fun t => Real.logb 2 (max (Nat.totient t.1) (Nat.totient t.2) : ℝ))
    (fun x _ => uEnt_class_ge hn x)

end CyclicTypeChannel