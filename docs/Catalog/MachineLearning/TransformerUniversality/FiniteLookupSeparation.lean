import Mathlib

/-!
# Exact finite lookup is *not* continuous universal approximation

`Catalog/MachineLearning/TransformerArchitecture.lean` proves exact universality of an
attention lookup table on a finite domain, and carefully flags that this is weaker than the
usual continuous universal-approximation statement.  This file turns that qualification into
a **quantitative separation theorem**.

Any architecture that first quantizes a real input to one of `N` finite tokens and then reads
a value table has range of size at most `N`.  We prove that such a model cannot approximate
even the identity function on `[0,1]` better than `1/(2N)`:

* `quantized_lookup_error_lower_bound` — a `Ω(1/N)` lower bound on the uniform error;
* `heads_needed_for_eps` — hence `N ≥ 1/(2ε)` tokens/heads are necessary for accuracy `ε`;
* `quantized_lookup_ne_id` — in particular the identity is never represented exactly.

Contrast this with `Catalog/MachineLearning/TransformerUniversality/SoftmaxLookup.lean`, where
`log (1/ε)` *score scale* suffices at fixed head count: the resource that scales cheaply is
the temperature, whereas the resource that must scale as `1/ε` is the number of lookup cells.
Together the two files delimit exactly what the finite universality theorem does and does not
give.
-/

open scoped BigOperators

namespace FiniteLookupSeparation

variable {X : Type*} [Fintype X] [Nonempty X]

/-- **Resolution lower bound for quantized lookup.**  If a model quantizes its real input
through `q : ℝ → X` and then reads a value table `f : X → ℝ`, its uniform error against the
identity on `[0,1]` is at least `1/(2 |X|)`. -/
theorem quantized_lookup_error_lower_bound (q : ℝ → X) (f : X → ℝ) (delta : ℝ)
    (hd : ∀ x ∈ Set.Icc (0:ℝ) 1, |f (q x) - x| ≤ delta) :
    1 / (2 * (Fintype.card X : ℝ)) ≤ delta := by
  classical
  set N : ℕ := Fintype.card X with hN
  have hNpos : 0 < N := Fintype.card_pos
  have hNR : (0:ℝ) < (N : ℝ) := by exact_mod_cast hNpos
  -- pigeonhole on the `N+1` grid points `k / N`
  have hmaps : ∀ k ∈ Finset.range (N + 1), q ((k : ℝ) / (N : ℝ)) ∈ (Finset.univ : Finset X) :=
    fun k _ => Finset.mem_univ _
  have hcard : (Finset.univ : Finset X).card < (Finset.range (N + 1)).card := by
    simp [hN]
  obtain ⟨k, hk, l, hl, hkl, heq⟩ :=
    Finset.exists_ne_map_eq_of_card_lt_of_maps_to hcard hmaps
  have hmem : ∀ m ∈ Finset.range (N + 1), ((m : ℝ) / (N : ℝ)) ∈ Set.Icc (0:ℝ) 1 := by
    intro m hm
    rw [Finset.mem_range] at hm
    constructor
    · positivity
    · rw [div_le_one hNR]
      exact_mod_cast Nat.lt_succ_iff.mp hm
  have h1 := hd _ (hmem k hk)
  have h2 := hd _ (hmem l hl)
  rw [heq] at h1
  -- the two grid points collapse to the same table entry, but are `1/N` apart
  have hsep : 1 / (N : ℝ) ≤ |(k : ℝ) / (N : ℝ) - (l : ℝ) / (N : ℝ)| := by
    have hne : ((k : ℝ) - (l : ℝ)) ≠ 0 := by
      intro h
      exact hkl (by exact_mod_cast sub_eq_zero.mp h)
    have hone : (1:ℝ) ≤ |(k : ℝ) - (l : ℝ)| := by
      have : (1:ℤ) ≤ |(k : ℤ) - (l : ℤ)| := by
        rcases lt_or_gt_of_ne (by exact_mod_cast hkl : (k:ℤ) ≠ (l:ℤ)) with h | h
        · rw [abs_of_nonpos (by omega)]; omega
        · rw [abs_of_nonneg (by omega)]; omega
      have hcast : |(k : ℝ) - (l : ℝ)| = ((|(k : ℤ) - (l : ℤ)| : ℤ) : ℝ) := by
        push_cast [abs_sub_comm]
        rw [abs_sub_comm]
      rw [hcast]
      exact_mod_cast this
    rw [div_sub_div_same, abs_div, abs_of_pos hNR]
    gcongr
  have htri : |(k : ℝ) / (N : ℝ) - (l : ℝ) / (N : ℝ)| ≤ 2 * delta := by
    calc |(k : ℝ) / (N : ℝ) - (l : ℝ) / (N : ℝ)|
        = |(f (q ((l:ℝ)/(N:ℝ))) - (l : ℝ) / (N : ℝ))
            - (f (q ((l:ℝ)/(N:ℝ))) - (k : ℝ) / (N : ℝ))| := by ring_nf
      _ ≤ |f (q ((l:ℝ)/(N:ℝ))) - (l : ℝ) / (N : ℝ)|
            + |f (q ((l:ℝ)/(N:ℝ))) - (k : ℝ) / (N : ℝ)| := abs_sub _ _
      _ ≤ 2 * delta := by linarith [h1, h2]
  have hfinal : 1 / (N : ℝ) ≤ 2 * delta := le_trans hsep htri
  rw [div_le_iff₀ (by positivity)] at hfinal ⊢
  linarith

/-- **General finite-range resolution bound.**  Any function whose values on `[0,1]` lie in a
finite set `S` has uniform error at least `1/(2|S|)` against the identity. -/
theorem finite_range_error_lower_bound (g : ℝ → ℝ) (S : Finset ℝ)
    (hmem : ∀ x ∈ Set.Icc (0:ℝ) 1, g x ∈ S) (delta : ℝ)
    (hd : ∀ x ∈ Set.Icc (0:ℝ) 1, |g x - x| ≤ delta) :
    1 / (2 * (S.card : ℝ)) ≤ delta := by
  classical
  have h0 : g 0 ∈ S := hmem 0 (by constructor <;> norm_num)
  haveI : Nonempty {a // a ∈ S} := ⟨⟨g 0, h0⟩⟩
  set q : ℝ → {a // a ∈ S} := fun x => if h : g x ∈ S then ⟨g x, h⟩ else ⟨g 0, h0⟩ with hq
  have hval : ∀ x ∈ Set.Icc (0:ℝ) 1, ((q x : {a // a ∈ S}) : ℝ) = g x := by
    intro x hx
    simp only [hq, dif_pos (hmem x hx)]
  have hd' : ∀ x ∈ Set.Icc (0:ℝ) 1, |((fun a : {a // a ∈ S} => (a : ℝ)) (q x)) - x| ≤ delta := by
    intro x hx
    show |((q x : {a // a ∈ S}) : ℝ) - x| ≤ delta
    rw [hval x hx]
    exact hd x hx
  have h := quantized_lookup_error_lower_bound q (fun a => (a : ℝ)) delta hd'
  rwa [Fintype.card_coe] at h

/-- **Depth does not buy resolution.**  However many layers precede it, a model whose final
stage reads a value table indexed by `X` still has uniform error at least `1/(2|X|)` on the
identity: the bottleneck is the number of distinct output values, not the depth. -/
theorem depth_does_not_help (pre : ℝ → ℝ) (q : ℝ → X) (f : X → ℝ) (delta : ℝ)
    (hd : ∀ x ∈ Set.Icc (0:ℝ) 1, |f (q (pre x)) - x| ≤ delta) :
    1 / (2 * (Fintype.card X : ℝ)) ≤ delta :=
  quantized_lookup_error_lower_bound (fun x => q (pre x)) f delta hd

/-- **The resolution bound is tight.**  The midpoint quantizer with `N` cells attains uniform
error exactly `1/(2N)` on the identity, so the lower bound above cannot be improved. -/
theorem exists_quantizer_error_le (N : ℕ) (hN : 0 < N) :
    ∃ (q : ℝ → Fin N) (f : Fin N → ℝ), ∀ x ∈ Set.Icc (0:ℝ) 1,
      |f (q x) - x| ≤ 1 / (2 * (N : ℝ)) := by
  have hNR : (0:ℝ) < (N : ℝ) := by exact_mod_cast hN
  refine ⟨fun x => ⟨min ⌊(N : ℝ) * x⌋₊ (N - 1), by omega⟩,
    fun a => ((a : ℕ) + 1/2) / (N : ℝ), ?_⟩
  intro x hx
  obtain ⟨hx0, hx1⟩ := hx
  set m : ℕ := min ⌊(N : ℝ) * x⌋₊ (N - 1) with hm
  have hnx : 0 ≤ (N : ℝ) * x := by positivity
  have hlow : (m : ℝ) ≤ (N : ℝ) * x := by
    rcases le_or_gt ⌊(N : ℝ) * x⌋₊ (N - 1) with hcase | hcase
    · have : m = ⌊(N : ℝ) * x⌋₊ := by omega
      rw [this]
      exact Nat.floor_le hnx
    · have hmN : m = N - 1 := by omega
      have hfl : (N : ℝ) ≤ (N : ℝ) * x := by
        have : N ≤ ⌊(N : ℝ) * x⌋₊ := by omega
        exact (Nat.le_floor_iff hnx).mp this
      rw [hmN]
      have : ((N - 1 : ℕ) : ℝ) ≤ (N : ℝ) := by
        have : (N - 1 : ℕ) ≤ N := Nat.sub_le _ _
        exact_mod_cast this
      linarith
  have hhigh : (N : ℝ) * x ≤ (m : ℝ) + 1 := by
    rcases le_or_gt ⌊(N : ℝ) * x⌋₊ (N - 1) with hcase | hcase
    · have hmeq : m = ⌊(N : ℝ) * x⌋₊ := by omega
      rw [hmeq]
      exact le_of_lt (Nat.lt_floor_add_one _)
    · have hmN : m = N - 1 := by omega
      have hcast : ((N - 1 : ℕ) : ℝ) + 1 = (N : ℝ) := by
        have h1 : (1:ℕ) ≤ N := hN
        rw [Nat.cast_sub h1]
        ring
      rw [hmN, hcast]
      calc (N : ℝ) * x ≤ (N : ℝ) * 1 := by nlinarith
        _ = (N : ℝ) := by ring
  have heq : ((m : ℝ) + 1/2) / (N : ℝ) - x = ((m : ℝ) + 1/2 - (N : ℝ) * x) / (N : ℝ) := by
    field_simp
  have habs : |(m : ℝ) + 1/2 - (N : ℝ) * x| ≤ 1/2 := by
    rw [abs_le]
    constructor <;> linarith
  have hkey : |((m : ℝ) + 1/2) / (N : ℝ) - x| ≤ 1 / (2 * (N : ℝ)) := by
    rw [heq, abs_div, abs_of_pos hNR]
    calc |(m : ℝ) + 1/2 - (N : ℝ) * x| / (N : ℝ) ≤ (1/2) / (N : ℝ) := by gcongr
      _ = 1 / (2 * (N : ℝ)) := by rw [div_div]
  show |((m : ℝ) + 1/2) / (N : ℝ) - x| ≤ 1 / (2 * (N : ℝ))
  exact hkey

/-- **Exact optimal resolution.**  Combining the two bounds: the best uniform error of an
`N`-cell quantized lookup model on the identity over `[0,1]` is exactly `1/(2N)`. -/
theorem optimal_quantizer_error (N : ℕ) (hN : 0 < N) :
    IsLeast {delta : ℝ | ∃ (q : ℝ → Fin N) (f : Fin N → ℝ),
      ∀ x ∈ Set.Icc (0:ℝ) 1, |f (q x) - x| ≤ delta} (1 / (2 * (N : ℝ))) := by
  haveI : Nonempty (Fin N) := ⟨⟨0, hN⟩⟩
  constructor
  · exact exists_quantizer_error_le N hN
  · rintro delta ⟨q, f, hd⟩
    have h := quantized_lookup_error_lower_bound (X := Fin N) q f delta hd
    simpa using h

/-- **Head/token count must scale like `1/ε`.**  Achieving uniform accuracy `ε` on the
identity forces at least `1/(2ε)` quantization cells — in sharp contrast with the `log (1/ε)`
*score scale* that suffices for a softmax lookup head at fixed head count. -/
theorem heads_needed_for_eps (q : ℝ → X) (f : X → ℝ) (eps : ℝ) (heps : 0 < eps)
    (hd : ∀ x ∈ Set.Icc (0:ℝ) 1, |f (q x) - x| ≤ eps) :
    1 / (2 * eps) ≤ (Fintype.card X : ℝ) := by
  have h := quantized_lookup_error_lower_bound q f eps hd
  have hNR : (0:ℝ) < (Fintype.card X : ℝ) := by
    exact_mod_cast (Fintype.card_pos : 0 < Fintype.card X)
  rw [div_le_iff₀ (by positivity)] at h
  rw [div_le_iff₀ (by positivity)]
  nlinarith

/-- No quantized lookup model computes the identity on `[0,1]` exactly. -/
theorem quantized_lookup_ne_id (q : ℝ → X) (f : X → ℝ) :
    ¬ (∀ x ∈ Set.Icc (0:ℝ) 1, f (q x) = x) := by
  intro hall
  have hd : ∀ x ∈ Set.Icc (0:ℝ) 1, |f (q x) - x| ≤ 0 := by
    intro x hx
    rw [hall x hx, sub_self, abs_zero]
  have h := quantized_lookup_error_lower_bound q f 0 hd
  have hNR : (0:ℝ) < (Fintype.card X : ℝ) := by
    exact_mod_cast (Fintype.card_pos : 0 < Fintype.card X)
  have : (0:ℝ) < 1 / (2 * (Fintype.card X : ℝ)) := by positivity
  linarith

end FiniteLookupSeparation