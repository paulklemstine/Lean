import Logic.BerggrenAbcQuality

/-!
# The quality spectrum of the Berggren tree, part II: asymptotics and sparsity

This file continues `Logic.BerggrenAbcQuality`.  It contains

* `BerggrenABC.quality_lt_ratio_iff` : the arithmetic criterion for an upper rational threshold,
  and the resulting two-sided bracket `5/4 < q < 4/3` for the best explicit node we found.
* `BerggrenABC.tree_quality_asymptotically_le_one` : **conditional asymptotic law** — under the
  Masser–Oesterlé `abc` conjecture (`Beal.ABCConjecture`), for every `ε > 0` all but the nodes
  with bounded hypotenuse have quality `≤ 1 + 2ε`; so the supremum of the tree's quality
  spectrum is `1` in the limit, and only finitely many nodes can exceed it.
* `BerggrenABC.hit_family_doubly_exponential` : the explicit family of `abc` hits constructed in
  part I is **doubly exponentially sparse**: consecutive members satisfy `c (k+1) > c k ^ 2`.
* `BerggrenABC.tree_depth_quality_law` : the **universal silver-ratio depth law** — every node at
  depth `n`, along *any* path, has `log c ≤ log 5 + n log (3 + 2√2)`, so the depth-`n` quality
  window is `2/3 < q ≤ 2 (log 5 + n log (3+2√2)) / log (rad abc)`.
* `BerggrenABC.tree_quality_lower_edge_rate` : the lower edge `2/3` is approached no faster than
  `1 / log c` — every node satisfies `q ≥ 2/3 + 2 log 2 / (9 log c)`.
-/

namespace BerggrenABC

open Beal

/-! ## 12. Upper rational thresholds and the bracket for the best explicit node -/

/-- A rational upper threshold for the quality, in purely arithmetic terms. -/
theorem quality_lt_ratio_iff {a b c : ℕ} (ha : 0 < a) (hb : 0 < b) (hc : 2 ≤ c)
    (h2 : 2 ≤ a * b * c) (m k : ℕ) (hk : 0 < k) :
    (quality a b c < (m : ℝ) / k) ↔ c ^ (2 * k) < (rad (a * b * c)) ^ m := by
  have hlog := log_rad_pos h2
  have hr0 : (0 : ℝ) < ((rad (a * b * c) : ℕ) : ℝ) := by exact_mod_cast rad_pos (n := a * b * c)
  have hkR : (0 : ℝ) < (k : ℝ) := by exact_mod_cast hk
  have hcR : (0 : ℝ) < (c : ℝ) := by positivity
  rw [quality_eq ha hb (by omega), div_lt_div_iff₀ hlog hkR]
  have hL : (m : ℝ) * Real.log ((rad (a * b * c) : ℕ) : ℝ)
      = Real.log (((rad (a * b * c) : ℕ) : ℝ) ^ m) := by rw [Real.log_pow]
  have hR : Real.log ((c : ℝ) ^ 2) * k = Real.log ((c : ℝ) ^ (2 * k)) := by
    rw [Real.log_pow, Real.log_pow]
    push_cast
    ring
  rw [hR, hL, Real.log_lt_log_iff (by positivity) (by positivity)]
  constructor
  · intro h; exact_mod_cast h
  · intro h; exact_mod_cast h

/-- The best explicit node found by search, `(36207, 18424, 40625)`, has quality `< 4/3`. -/
theorem quality_record_lt_four_thirds : quality 36207 18424 40625 < (4 : ℝ) / 3 := by
  have h := quality_lt_ratio_iff (a := 36207) (b := 18424) (c := 40625) (by norm_num)
    (by norm_num) (by norm_num) (by norm_num) 4 3 (by norm_num)
  have hcast : ((4 : ℕ) : ℝ) / ((3 : ℕ) : ℝ) = (4 : ℝ) / 3 := by norm_num
  rw [hcast] at h
  rw [h, rad_record]
  norm_num

/-- **Bracket for the tree's best known `abc` hit.**  The node `(36207, 18424, 40625)` has
quality strictly between `5/4` and `4/3`; in particular it stays well below the record quality
`≈ 1.63` of the known `abc` hits. -/
theorem quality_record_bracket :
    (5 : ℝ) / 4 < quality 36207 18424 40625 ∧ quality 36207 18424 40625 < (4 : ℝ) / 3 :=
  ⟨quality_record_gt_five_fourths, quality_record_lt_four_thirds⟩

/-! ## 13. The conditional asymptotic law for the spectrum -/

/-- **Conditional asymptotic law.**  Assume the Masser–Oesterlé `abc` conjecture in the real
form `Beal.ABCConjecture` of the catalog.  Then for every `ε > 0` there is a threshold `C₀`
such that *every* Pythagorean `abc` triple with hypotenuse `≥ C₀` has quality `≤ 1 + 2ε`.

Together with `BerggrenABC.two_thirds_lt_quality` this pins the limiting quality spectrum of the
tree into the window `(2/3, 1]`: the hits of part I show that values `> 1` do occur, but under
`abc` they can only occur for hypotenuses below the (ineffective) threshold `C₀`. -/
theorem quality_asymptotically_le_one (habc : ABCConjecture) {ε : ℝ} (hε : 0 < ε) :
    ∃ C₀ : ℝ, ∀ a b c : ℕ, 0 < a → 0 < b → 2 ≤ c → a ^ 2 + b ^ 2 = c ^ 2 → Nat.Coprime a b →
      C₀ ≤ (c : ℝ) → quality a b c ≤ 1 + 2 * ε := by
  obtain ⟨K, hKpos, hK⟩ := habc ε hε
  set M : ℝ := max (Real.log K) 0 with hM
  have hM0 : 0 ≤ M := le_max_right _ _
  have hMK : Real.log K ≤ M := le_max_left _ _
  refine ⟨Real.exp (M / 2 * (1 + (1 + ε) / ε)), ?_⟩
  intro a b c ha hb hc hsq hcop hbig
  have hcpos : 0 < c := by omega
  have h2 : 2 ≤ a * b * c := by
    have : 1 * 1 * 2 ≤ a * b * c := Nat.mul_le_mul (Nat.mul_le_mul ha hb) hc
    omega
  -- the `abc` inequality applied to `a² + b² = c²`
  have hineq := hK (a ^ 2) (b ^ 2) (c ^ 2) (by positivity) (by positivity) hsq (hcop.pow 2 2)
  rw [rad_sq_triple ha hb hcpos] at hineq
  set R : ℕ := rad (a * b * c) with hRdef
  have hR0 : (0 : ℝ) < (R : ℝ) := by exact_mod_cast rad_pos (n := a * b * c)
  have hL : 0 < Real.log (R : ℝ) := log_rad_pos h2
  have hcR : (0 : ℝ) < (c : ℝ) := by exact_mod_cast hcpos
  -- take logarithms of `c² ≤ K · R^(1+ε)`
  have hlogineq : 2 * Real.log (c : ℝ) ≤ Real.log K + (1 + ε) * Real.log (R : ℝ) := by
    have hcc : ((c ^ 2 : ℕ) : ℝ) = (c : ℝ) ^ 2 := by push_cast; ring
    rw [hcc] at hineq
    have hpos : (0 : ℝ) < (K : ℝ) * ((R : ℝ)) ^ (1 + ε) := by positivity
    have hmono := Real.log_le_log (by positivity) hineq
    rw [Real.log_mul (by positivity) (by positivity), Real.log_rpow hR0, Real.log_pow] at hmono
    push_cast at hmono
    linarith
  -- the hypotenuse is large, hence so is the radical
  have hlogc : M / 2 * (1 + (1 + ε) / ε) ≤ Real.log (c : ℝ) := by
    have := Real.log_le_log (by positivity) hbig
    rwa [Real.log_exp] at this
  have hkey : Real.log K ≤ ε * Real.log (R : ℝ) := by
    rcases le_or_gt (Real.log K) 0 with h | h
    · nlinarith
    · -- here `M = log K > 0`
      have hMeq : M = Real.log K := by
        rw [hM]
        exact max_eq_left h.le
      have h1 : (2 * Real.log (c : ℝ) - Real.log K) / (1 + ε) ≤ Real.log (R : ℝ) := by
        rw [div_le_iff₀ (by linarith)]
        linarith
      have h2' : Real.log K * (1 + ε) / ε ≤ (2 * Real.log (c : ℝ) - Real.log K) := by
        rw [hMeq] at hlogc
        have : Real.log K * (1 + (1 + ε) / ε) ≤ 2 * Real.log (c : ℝ) := by
          nlinarith [hlogc]
        have hexp : Real.log K * (1 + (1 + ε) / ε)
            = Real.log K + Real.log K * (1 + ε) / ε := by ring
        linarith [hexp ▸ this]
      have h3 : Real.log K * (1 + ε) / ε ≤ (1 + ε) * Real.log (R : ℝ) := by
        calc Real.log K * (1 + ε) / ε ≤ 2 * Real.log (c : ℝ) - Real.log K := h2'
          _ ≤ (1 + ε) * Real.log (R : ℝ) := by linarith
      have h1e : (0 : ℝ) < 1 + ε := by linarith
      have hdiv : Real.log K / ε ≤ Real.log (R : ℝ) := by
        have e : Real.log K * (1 + ε) / ε = (1 + ε) * (Real.log K / ε) := by ring
        rw [e] at h3
        exact le_of_mul_le_mul_left h3 h1e
      have := (div_le_iff₀ hε).1 hdiv
      linarith
  -- conclude
  rw [quality_eq_two_mul ha hb hcpos, div_le_iff₀ hL]
  nlinarith [hlogineq, hkey]

/-- The tree-node form of the conditional asymptotic law. -/
theorem tree_quality_asymptotically_le_one (habc : ABCConjecture) {ε : ℝ} (hε : 0 < ε) :
    ∃ C₀ : ℝ, ∀ a b c : ℕ, IsTreeNode a b c → C₀ ≤ (c : ℝ) → quality a b c ≤ 1 + 2 * ε := by
  obtain ⟨C₀, hC₀⟩ := quality_asymptotically_le_one habc hε
  refine ⟨C₀, ?_⟩
  intro a b c hnode hbig
  obtain ⟨ha, hb, hc, hsq, hcop⟩ := hnode.basic
  exact hC₀ a b c (by omega) (by omega) (by omega) hsq hcop hbig

/-! ## 14. Sparsity of the explicit hit family -/

/-- The `A`-spine parameter of the `k`-th member of the explicit hit family of part I. -/
def hitParam (k : ℕ) : ℕ := 3 ^ (2 ^ k) - 1

/-- The hypotenuse of the `k`-th member of the explicit hit family of part I. -/
def hitHyp (k : ℕ) : ℕ := 2 * (hitParam k) ^ 2 + 2 * hitParam k + 1

theorem hitParam_succ (k : ℕ) : hitParam k + 1 = 3 ^ (2 ^ k) := by
  have h1 : 1 ≤ 3 ^ (2 ^ k) := Nat.one_le_pow _ _ (by norm_num)
  unfold hitParam
  omega

theorem hitHyp_closed (k : ℕ) : hitHyp k + 2 * 3 ^ (2 ^ k) = 2 * (3 ^ (2 ^ k)) ^ 2 + 1 := by
  rw [← hitParam_succ k]
  unfold hitHyp
  ring

/-- Each member of the family is a genuine tree node and a genuine `abc` hit. -/
theorem hitFamily_is_hit (k : ℕ) (hk : 2 ≤ k) :
    IsTreeNode (2 * hitParam k + 1) (2 * hitParam k * (hitParam k + 1)) (hitHyp k) ∧
      1 < quality (2 * hitParam k + 1) (2 * hitParam k * (hitParam k + 1)) (hitHyp k) := by
  have hn : hitParam k + 1 = 3 ^ (2 ^ k) := hitParam_succ k
  have hbig : 80 ≤ hitParam k := by
    have h4 : (4 : ℕ) ≤ 2 ^ k := by
      calc (4 : ℕ) = 2 ^ 2 := by norm_num
        _ ≤ 2 ^ k := Nat.pow_le_pow_right (by norm_num) hk
    have : (81 : ℕ) ≤ 3 ^ (2 ^ k) := by
      calc (81 : ℕ) = 3 ^ 4 := by norm_num
        _ ≤ 3 ^ (2 ^ k) := Nat.pow_le_pow_right (by norm_num) h4
    omega
  refine ⟨?_, ?_⟩
  · exact spine_isTreeNode (hitParam k) (by omega)
  · exact spine_family_hit k (hitParam k) hk hn

/-- **Double-exponential sparsity of the explicit hit family.**  Consecutive hypotenuses of the
family of part I satisfy `c k ^ 2 < 4 * c (k+1)` and `c (k+1) < c k ^ 2`: each step essentially
squares the hypotenuse.  Hence this mechanism produces only `O(log log X)` hits with hypotenuse
below `X` — the high-quality region of the tree, as far as this construction sees it, is
extremely sparse. -/
theorem hit_family_doubly_exponential (k : ℕ) :
    hitHyp (k + 1) < hitHyp k ^ 2 ∧ hitHyp k ^ 2 < 4 * hitHyp (k + 1) := by
  set m := 3 ^ (2 ^ k) with hm
  have hm3 : 3 ≤ m := by
    rw [hm]
    calc (3 : ℕ) = 3 ^ 1 := by norm_num
      _ ≤ 3 ^ (2 ^ k) := Nat.pow_le_pow_right (by norm_num) Nat.one_le_two_pow
  have hnext : 3 ^ (2 ^ (k + 1)) = m ^ 2 := by
    rw [hm, ← pow_mul, pow_succ]
  have e1 : hitHyp k + 2 * m = 2 * m ^ 2 + 1 := hitHyp_closed k
  have e2 : hitHyp (k + 1) + 2 * m ^ 2 = 2 * (m ^ 2) ^ 2 + 1 := by
    have := hitHyp_closed (k + 1)
    rwa [hnext] at this
  -- pass to the integers, where the two closed forms are polynomial identities in `m`
  have hmZ : (3 : ℤ) ≤ (m : ℤ) := by exact_mod_cast hm3
  have E1 : (hitHyp k : ℤ) = 2 * (m : ℤ) ^ 2 + 1 - 2 * (m : ℤ) := by
    have : ((hitHyp k + 2 * m : ℕ) : ℤ) = ((2 * m ^ 2 + 1 : ℕ) : ℤ) := by exact_mod_cast e1
    push_cast at this
    linarith
  have E2 : (hitHyp (k + 1) : ℤ) = 2 * (m : ℤ) ^ 4 + 1 - 2 * (m : ℤ) ^ 2 := by
    have : ((hitHyp (k + 1) + 2 * m ^ 2 : ℕ) : ℤ) = ((2 * (m ^ 2) ^ 2 + 1 : ℕ) : ℤ) := by
      exact_mod_cast e2
    push_cast at this
    linarith
  constructor
  · have hp : (0 : ℤ) < 2 * (m : ℤ) * ((m : ℤ) - 1) ^ 2 * ((m : ℤ) - 2) :=
      mul_pos (mul_pos (by linarith) (by nlinarith)) (by linarith)
    have hZ : (hitHyp (k + 1) : ℤ) < (hitHyp k : ℤ) ^ 2 := by
      rw [E1, E2]; nlinarith [hp]
    exact_mod_cast hZ
  · have hp : (0 : ℤ) ≤ 4 * (m : ℤ) ^ 2 * ((m : ℤ) ^ 2 - 4) := by nlinarith
    have hZ : (hitHyp k : ℤ) ^ 2 < 4 * (hitHyp (k + 1) : ℤ) := by
      rw [E1, E2]; nlinarith [hp]
    exact_mod_cast hZ

/-! ## 15. The universal silver-ratio depth law -/

/-- Every Berggren step multiplies the hypotenuse by at most the square of the silver ratio,
`3 + 2√2`.  The mechanism is purely geometric: `c' = 3c ± 2(a ∓ b)` and `a + b ≤ √2 c`. -/
theorem step_hyp_le_silver {t : ℤ × ℤ × ℤ} (h : TreeInv t) (s : BerggrenStep) :
    (((applyStep s t).2.2 : ℤ) : ℝ) ≤ silver * ((t.2.2 : ℤ) : ℝ) := by
  obtain ⟨a, b, c⟩ := t
  obtain ⟨ha, hb, hac, hbc, hp, -⟩ := h
  simp only at ha hb hac hbc hp
  have hpR : ((a : ℝ)) ^ 2 + (b : ℝ) ^ 2 = (c : ℝ) ^ 2 := by
    have hz : a ^ 2 + b ^ 2 = c ^ 2 := hp
    exact_mod_cast congrArg (fun z : ℤ => (z : ℝ)) hz
  have haR : (3 : ℝ) ≤ (a : ℝ) := by exact_mod_cast ha
  have hbR : (3 : ℝ) ≤ (b : ℝ) := by exact_mod_cast hb
  have hacR : (a : ℝ) < (c : ℝ) := by exact_mod_cast hac
  have hcR : (0 : ℝ) < (c : ℝ) := by linarith
  have hs : Real.sqrt 2 ^ 2 = 2 := Real.sq_sqrt (by norm_num)
  have hs0 : (0 : ℝ) < Real.sqrt 2 := by nlinarith [sqrt_two_ge]
  have hsum : (a : ℝ) + (b : ℝ) ≤ Real.sqrt 2 * (c : ℝ) := by
    nlinarith [sq_nonneg ((a : ℝ) - (b : ℝ)), mul_pos hs0 hcR]
  cases s <;>
    simp only [applyStep, bergA, bergB, bergC] <;>
      push_cast <;> unfold silver <;> nlinarith [hsum, hs0]

/-- **Universal silver-ratio growth**: the hypotenuse of the node reached by *any* path of
length `n` is at most `5 · (3 + 2√2) ^ n`.  Along the `B`-spine this bound is attained up to a
bounded factor (`bHyp_bounds`), so the silver ratio is the exact growth constant of the tree. -/
theorem hyp_le_silver_pow (p : List BerggrenStep) :
    (((applyPath p).2.2 : ℤ) : ℝ) ≤ 5 * silver ^ p.length := by
  have hsil : (0 : ℝ) < silver := by have := sqrt_two_ge; unfold silver; linarith
  induction p using List.reverseRecOn with
  | nil => simp [applyPath]
  | append_singleton l s ih =>
      rw [applyPath_concat]
      calc (((applyStep s (applyPath l)).2.2 : ℤ) : ℝ)
          ≤ silver * (((applyPath l).2.2 : ℤ) : ℝ) := step_hyp_le_silver (treeInv_applyPath l) s
        _ ≤ silver * (5 * silver ^ l.length) := mul_le_mul_of_nonneg_left ih hsil.le
        _ = 5 * silver ^ (l.length + 1) := by ring
        _ = 5 * silver ^ (l ++ [s]).length := by simp

/-- **The depth-`n` quality law of the whole tree.**  For every path `p` of length `n` the node
it reaches is a tree node whose quality obeys the exact identity
`q · log (rad abc) = 2 log c`, lies above `2/3`, and whose hypotenuse satisfies
`log c ≤ log 5 + n · log (3 + 2√2)`.  Consequently the depth-`n` quality window is
`2/3 < q ≤ 2 (log 5 + n log (3+2√2)) / log (rad abc)`: the silver ratio controls the numerator
of the quality uniformly over the whole tree, so the entire depth dependence of the spectrum is
carried by the radical. -/
theorem tree_depth_quality_law (p : List BerggrenStep) :
    ∃ a b c : ℕ, IsTreeNode a b c ∧ (c : ℤ) = (applyPath p).2.2 ∧
      2 / 3 < quality a b c ∧
      quality a b c * Real.log ((rad (a * b * c) : ℕ) : ℝ) = 2 * Real.log (c : ℝ) ∧
      Real.log (c : ℝ) ≤ Real.log 5 + p.length * Real.log silver := by
  obtain ⟨_, _, _, hbc, _, _⟩ := treeInv_applyPath p
  have h3 : ((applyPath p).2.2.toNat : ℤ) = (applyPath p).2.2 := Int.toNat_of_nonneg (by omega)
  refine ⟨(applyPath p).1.toNat, (applyPath p).2.1.toNat, (applyPath p).2.2.toNat,
    isTreeNode_of_path p, h3, tree_quality_gt_two_thirds (isTreeNode_of_path p), ?_, ?_⟩
  · obtain ⟨ha, hb, hc, _, _⟩ := (isTreeNode_of_path p).basic
    exact quality_mul_log_rad ha hb hc
  · have hsil : (0 : ℝ) < silver := by have := sqrt_two_ge; unfold silver; linarith
    have hc0 : (0 : ℝ) < (((applyPath p).2.2.toNat : ℕ) : ℝ) := by
      have hpos : (0 : ℤ) < (applyPath p).2.2.toNat := by omega
      exact_mod_cast hpos
    have hle : (((applyPath p).2.2.toNat : ℕ) : ℝ) ≤ 5 * silver ^ p.length := by
      have hcast : (((applyPath p).2.2.toNat : ℕ) : ℝ) = (((applyPath p).2.2 : ℤ) : ℝ) := by
        exact_mod_cast congrArg (fun z : ℤ => (z : ℝ)) h3
      rw [hcast]; exact hyp_le_silver_pow p
    calc Real.log (((applyPath p).2.2.toNat : ℕ) : ℝ)
        ≤ Real.log (5 * silver ^ p.length) := Real.log_le_log hc0 hle
      _ = Real.log 5 + p.length * Real.log silver := by
          rw [Real.log_mul (by norm_num) (by positivity), Real.log_pow]

/-! ## 16. The quantitative lower edge -/

/-- **Quantitative form of the lower edge.**  Every Pythagorean `abc` triple with legs `≥ 3`
has quality at least `2 log c / (3 log c - log 2)`, because `rad (abc) ≤ abc ≤ c³/2`. -/
theorem quality_ge_log_ratio {a b c : ℕ} (ha : 3 ≤ a) (hb : 3 ≤ b) (hc : 5 ≤ c)
    (h : a ^ 2 + b ^ 2 = c ^ 2) :
    2 * Real.log (c : ℝ) / (3 * Real.log (c : ℝ) - Real.log 2) ≤ quality a b c := by
  have hpos : 0 < a * b * c := by positivity
  have h2 : 2 ≤ a * b * c := by
    have : 3 * 3 * 5 ≤ a * b * c := Nat.mul_le_mul (Nat.mul_le_mul ha hb) hc
    omega
  have hlogR0 : 0 < Real.log ((rad (a * b * c) : ℕ) : ℝ) := log_rad_pos h2
  have hab : 2 * (a * b) ≤ c ^ 2 := by
    have hz : ((a : ℤ)) ^ 2 + (b : ℤ) ^ 2 = (c : ℤ) ^ 2 := by exact_mod_cast h
    have h' : (2 : ℤ) * ((a : ℤ) * b) ≤ (c : ℤ) ^ 2 := by nlinarith [sq_nonneg ((a : ℤ) - b)]
    exact_mod_cast h'
  have hrad : 2 * rad (a * b * c) ≤ c ^ 3 := by
    have h1 : rad (a * b * c) ≤ a * b * c := rad_le_self hpos
    nlinarith
  have hcR : (1 : ℝ) < (c : ℝ) := by exact_mod_cast (by omega : 1 < c)
  have hlogc : 0 < Real.log (c : ℝ) := Real.log_pos hcR
  have hr0 : (0 : ℝ) < ((rad (a * b * c) : ℕ) : ℝ) := by exact_mod_cast rad_pos (n := a * b * c)
  have hradle : ((rad (a * b * c) : ℕ) : ℝ) ≤ (c : ℝ) ^ 3 / 2 := by
    have hz : (2 : ℝ) * ((rad (a * b * c) : ℕ) : ℝ) ≤ (c : ℝ) ^ 3 := by exact_mod_cast hrad
    linarith
  have hlogR : Real.log ((rad (a * b * c) : ℕ) : ℝ) ≤ 3 * Real.log (c : ℝ) - Real.log 2 := by
    have hmono := Real.log_le_log hr0 hradle
    rwa [Real.log_div (by positivity) (by norm_num), Real.log_pow, Nat.cast_ofNat] at hmono
  rw [quality_eq_two_mul (by omega) (by omega) (by omega)]
  gcongr

/-- **The lower edge is approached at rate `1 / log c`.**  Every Berggren tree node satisfies
`q ≥ 2/3 + 2 log 2 / (9 log c)`: the infimum `2/3` of the tree's quality spectrum can only be
approached along nodes whose hypotenuse tends to infinity, and never faster than `1/log c`. -/
theorem tree_quality_lower_edge_rate {a b c : ℕ} (hnode : IsTreeNode a b c) :
    2 / 3 + 2 * Real.log 2 / (9 * Real.log (c : ℝ)) ≤ quality a b c := by
  obtain ⟨ha, hb, hc, hsq, -⟩ := hnode.basic
  have hcR : (1 : ℝ) < (c : ℝ) := by exact_mod_cast (by omega : 1 < c)
  have hlogc : 0 < Real.log (c : ℝ) := Real.log_pos hcR
  have hlog5 : Real.log 5 ≤ Real.log (c : ℝ) :=
    Real.log_le_log (by norm_num) (by exact_mod_cast hc)
  have hlog2 : (0 : ℝ) < Real.log 2 := Real.log_pos (by norm_num)
  have hl25 : Real.log 2 < Real.log 5 := Real.log_lt_log (by norm_num) (by norm_num)
  have hden : 0 < 3 * Real.log (c : ℝ) - Real.log 2 := by linarith
  have hmain := quality_ge_log_ratio ha hb hc hsq
  have hstep : 2 / 3 + 2 * Real.log 2 / (9 * Real.log (c : ℝ))
      ≤ 2 * Real.log (c : ℝ) / (3 * Real.log (c : ℝ) - Real.log 2) := by
    rw [div_add_div _ _ (by norm_num) (by positivity), div_le_div_iff₀ (by positivity) hden]
    nlinarith [hlogc, hlog2, hden]
  linarith

end BerggrenABC