/-
# Ranks of apparition on the Pell spine, and the prime `13`

`Novelty.PellSpineDivisibility` shows that the Pell numbers are a strong divisibility
sequence.  Here we combine that with a pigeonhole argument in `ZMod m × ZMod m` to obtain
the *rank of apparition* theory, and then use it to falsify two more conjectures.

## Proved

* `pell_apparition` — **every** modulus `m ≥ 1` divides some positive Pell number.  The
  state map `n ↦ (P n, P (n+1))` into the finite set `ZMod m × ZMod m` cannot be injective,
  and the recursion is *reversible* (`P n = P (n+2) - 2 P (n+1)`), so any repetition can be
  pushed all the way back to index `0`;
* `pellRank` — the resulting rank of apparition, `pellRank m = min {n > 0 : m ∣ P n}`;
* `dvd_pellP_iff_pellRank_dvd` — **the exact divisibility law**
  `m ∣ P n ↔ pellRank m ∣ n`, proved by feeding strong divisibility into minimality.
  Combinatorics (pigeonhole) and arithmetic (gcd) meet here;
* `pellRank_mul_of_coprime` — `pellRank (a*b) = lcm (pellRank a) (pellRank b)` for coprime
  `a, b`: the rank is determined by its prime-power values.

## Refuted

* `not_pellRank_dvd_sub_one` — the Fermat-style guess `pellRank p ∣ p - 1` fails at `p = 3`
  (`pellRank 3 = 4`, and `4 ∤ 2`); the correct exponent involves the Legendre symbol `(2/p)`;
* `not_pellRank_sq` — the Wall–Sun–Sun-style guess `pellRank (p²) = p * pellRank p` fails at
  `p = 13`: since `P 7 = 169 = 13²` we get `pellRank 169 = 7 = pellRank 13`.  So `13` is a
  *Pell–Wall–Sun–Sun prime*, whereas no Fibonacci–Wall–Sun–Sun prime is known at all.
-/
import Novelty.PellSpineDivisibility

namespace Catalog.Novelty.PellSpine

/-! ## Existence of the rank of apparition -/

/-- **Apparition theorem**: every positive modulus divides some positive Pell number.
Pigeonhole on the reversible state map `n ↦ (P n, P (n+1)) ∈ ZMod m × ZMod m`. -/
theorem pell_apparition (m : ℕ) (hm : 0 < m) : ∃ n, 0 < n ∧ m ∣ pellP n := by
  haveI : NeZero m := ⟨hm.ne'⟩
  set f : ℕ → ZMod m × ZMod m := fun n => ((pellP n : ZMod m), (pellP (n + 1) : ZMod m))
    with hf
  -- the recursion can be run backwards
  have hback : ∀ a b : ℕ, f (a + 1) = f (b + 1) → f a = f b := by
    intro a b h
    have h1 : ((pellP (a + 1) : ℕ) : ZMod m) = ((pellP (b + 1) : ℕ) : ZMod m) :=
      congrArg Prod.fst h
    have h2 : ((pellP (a + 2) : ℕ) : ZMod m) = ((pellP (b + 2) : ℕ) : ZMod m) :=
      congrArg Prod.snd h
    have e : ∀ n : ℕ, ((pellP (n + 2) : ℕ) : ZMod m)
        = 2 * ((pellP (n + 1) : ℕ) : ZMod m) + ((pellP n : ℕ) : ZMod m) := by
      intro n; rw [pellP_add_two]; push_cast; ring
    rw [e a, e b] at h2
    have h0 : ((pellP a : ℕ) : ZMod m) = ((pellP b : ℕ) : ZMod m) := by
      linear_combination h2 - 2 * h1
    exact Prod.ext h0 h1
  -- hence a repetition slides down to the origin
  have hshift : ∀ t i : ℕ, f i = f (i + t) → f 0 = f t := by
    intro t i
    induction i with
    | zero => simp
    | succ i ih =>
        intro h
        refine ih (hback i (i + t) ?_)
        rw [show i + t + 1 = i + 1 + t by ring]
        exact h
  have key : ∀ i j : ℕ, i < j → f i = f j → ∃ n, 0 < n ∧ m ∣ pellP n := by
    intro i j hij hfij
    obtain ⟨t, ht⟩ : ∃ t, j = i + t := ⟨j - i, by omega⟩
    subst ht
    have h0 := hshift t i hfij
    have h1 : (f t).1 = (f 0).1 := congrArg Prod.fst h0.symm
    rw [hf] at h1
    simp only [pellP_zero, Nat.cast_zero] at h1
    exact ⟨t, by omega, (ZMod.natCast_eq_zero_iff _ _).mp h1⟩
  obtain ⟨a, b, hab, hfab⟩ := Finite.exists_ne_map_eq_of_infinite f
  rcases lt_or_gt_of_ne hab with h | h
  · exact key a b h hfab
  · exact key b a h hfab.symm

/-- The **rank of apparition** of `m`: the least positive index whose Pell number is
divisible by `m` (and `0` for the degenerate modulus `m = 0`). -/
noncomputable def pellRank (m : ℕ) : ℕ :=
  if h : 0 < m then Nat.find (pell_apparition m h) else 0

theorem pellRank_spec {m : ℕ} (hm : 0 < m) : 0 < pellRank m ∧ m ∣ pellP (pellRank m) := by
  rw [pellRank, dif_pos hm]
  exact Nat.find_spec (pell_apparition m hm)

theorem pellRank_pos {m : ℕ} (hm : 0 < m) : 0 < pellRank m := (pellRank_spec hm).1

theorem dvd_pellP_pellRank {m : ℕ} (hm : 0 < m) : m ∣ pellP (pellRank m) :=
  (pellRank_spec hm).2

theorem pellRank_le {m n : ℕ} (hm : 0 < m) (hn : 0 < n) (h : m ∣ pellP n) : pellRank m ≤ n := by
  rw [pellRank, dif_pos hm]
  exact Nat.find_le ⟨hn, h⟩

/-! ## The exact divisibility law -/

/-- **The divisibility law of the Pell spine**: `m ∣ P n` happens exactly at the multiples
of the rank of apparition.  Pigeonhole gives existence, strong divisibility gives rigidity. -/
theorem dvd_pellP_iff_pellRank_dvd {m : ℕ} (hm : 0 < m) (n : ℕ) :
    m ∣ pellP n ↔ pellRank m ∣ n := by
  constructor
  · intro h
    rcases Nat.eq_zero_or_pos n with rfl | hn
    · simp
    · -- `m` divides `P (gcd (rank m) n)`, so minimality forces the gcd to be the rank
      set r := pellRank m with hr
      have h1 : m ∣ Nat.gcd (pellP r) (pellP n) :=
        Nat.dvd_gcd (dvd_pellP_pellRank hm) h
      rw [pellP_gcd] at h1
      have hg : 0 < Nat.gcd r n := Nat.gcd_pos_of_pos_right _ hn
      have hle : r ≤ Nat.gcd r n := pellRank_le hm hg h1
      have : Nat.gcd r n = r := le_antisymm (Nat.gcd_le_left _ (pellRank_pos hm)) hle
      exact Nat.gcd_eq_left_iff_dvd.mp this
  · intro h
    exact dvd_trans (dvd_pellP_pellRank hm) ((pellP_dvd_iff _ _).mp h)

/-- Ranks of apparition are determined prime-power by prime-power. -/
theorem pellRank_mul_of_coprime {a b : ℕ} (ha : 0 < a) (hb : 0 < b) (hab : Nat.Coprime a b) :
    pellRank (a * b) = Nat.lcm (pellRank a) (pellRank b) := by
  have hab0 : 0 < a * b := Nat.mul_pos ha hb
  have hiff : ∀ n : ℕ, pellRank (a * b) ∣ n ↔ Nat.lcm (pellRank a) (pellRank b) ∣ n := by
    intro n
    rw [← dvd_pellP_iff_pellRank_dvd hab0]
    constructor
    · intro h
      exact Nat.lcm_dvd ((dvd_pellP_iff_pellRank_dvd ha n).mp ((dvd_mul_right a b).trans h))
        ((dvd_pellP_iff_pellRank_dvd hb n).mp ((dvd_mul_left b a).trans h))
    · intro h
      refine hab.mul_dvd_of_dvd_of_dvd ?_ ?_
      · exact (dvd_pellP_iff_pellRank_dvd ha n).mpr ((Nat.dvd_lcm_left _ _).trans h)
      · exact (dvd_pellP_iff_pellRank_dvd hb n).mpr ((Nat.dvd_lcm_right _ _).trans h)
  exact Nat.dvd_antisymm ((hiff _).mpr dvd_rfl) ((hiff _).mp dvd_rfl)

/-! ## Two computed ranks -/

theorem pellRank_three : pellRank 3 = 4 := by
  have h3 : (0 : ℕ) < 3 := by norm_num
  refine le_antisymm (pellRank_le h3 (by norm_num) (by decide)) ?_
  by_contra hlt
  push_neg at hlt
  have hpos := pellRank_pos h3
  have hdvd := dvd_pellP_pellRank h3
  interval_cases h : pellRank 3 <;> simp_all <;> revert hdvd <;> decide

theorem pellRank_thirteen : pellRank 13 = 7 := by
  have h13 : (0 : ℕ) < 13 := by norm_num
  refine le_antisymm (pellRank_le h13 (by norm_num) (by decide)) ?_
  by_contra hlt
  push_neg at hlt
  have hpos := pellRank_pos h13
  have hdvd := dvd_pellP_pellRank h13
  interval_cases h : pellRank 13 <;> simp_all <;> revert hdvd <;> decide

theorem pellRank_onesixtynine : pellRank 169 = 7 := by
  have h169 : (0 : ℕ) < 169 := by norm_num
  refine le_antisymm (pellRank_le h169 (by norm_num) (by decide)) ?_
  by_contra hlt
  push_neg at hlt
  have hpos := pellRank_pos h169
  have hdvd := dvd_pellP_pellRank h169
  interval_cases h : pellRank 169 <;> simp_all <;> revert hdvd <;> decide

theorem pellRank_thirtyone : pellRank 31 = 30 := by
  have h31 : (0 : ℕ) < 31 := by norm_num
  refine le_antisymm (pellRank_le h31 (by norm_num) (by decide)) ?_
  by_contra hlt
  push_neg at hlt
  have hpos := pellRank_pos h31
  have hdvd := dvd_pellP_pellRank h31
  interval_cases h : pellRank 31 <;> simp_all <;> revert hdvd <;> decide

theorem pellRank_thirtyone_sq : pellRank 961 = 30 := by
  have h961 : (0 : ℕ) < 961 := by norm_num
  refine le_antisymm (pellRank_le h961 (by norm_num) (by decide)) ?_
  by_contra hlt
  push_neg at hlt
  have hpos := pellRank_pos h961
  have hdvd := dvd_pellP_pellRank h961
  interval_cases h : pellRank 961 <;> simp_all <;> revert hdvd <;> decide

/-! ## Two refutations -/

/-- **Refutation.**  `pellRank p ∣ p - 1` is false for `p = 3`: the rank is `4`, and `4 ∤ 2`.
(The genuine law is `pellRank p ∣ p - (2/p)`, and `2` is a non-residue modulo `3`.) -/
theorem not_pellRank_dvd_sub_one :
    ¬ ∀ p : ℕ, Nat.Prime p → 2 < p → pellRank p ∣ (p - 1) := by
  intro h
  have h3 := h 3 (by norm_num) (by norm_num)
  rw [pellRank_three] at h3
  norm_num at h3

/-- **Refutation.**  The Wall–Sun–Sun-style law `pellRank (p²) = p * pellRank p` fails at
`p = 13`, because `P 7 = 169 = 13²`.  Thus `13` is a *Pell–Wall–Sun–Sun prime*: the rank does
not grow when passing from `13` to `13²`. -/
theorem not_pellRank_sq :
    ¬ ∀ p : ℕ, Nat.Prime p → pellRank (p ^ 2) = p * pellRank p := by
  intro h
  have h13 := h 13 (by norm_num)
  rw [pellRank_thirteen, show (13 : ℕ) ^ 2 = 169 from by norm_num, pellRank_onesixtynine] at h13
  norm_num at h13

/-- The structural reason: `13² ∣ P 7`, so the rank of `13²` cannot exceed that of `13`. -/
theorem pell_wall_sun_sun_thirteen : (13 : ℕ) ^ 2 ∣ pellP 7 := by decide

/-- A **second** Pell–Wall–Sun–Sun prime: `31² ∣ P 30 = 107578520350`. -/
theorem pell_wall_sun_sun_thirtyone : (31 : ℕ) ^ 2 ∣ pellP 30 := by decide

/-- So the phenomenon is not a one-off accident of `13`: at least two primes fail the
Wall–Sun–Sun growth law on the Pell spine.  (For Fibonacci numbers not a single such prime
is known.) -/
theorem two_pell_wall_sun_sun_primes :
    ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ p ≠ q ∧
      pellRank (p ^ 2) = pellRank p ∧ pellRank (q ^ 2) = pellRank q := by
  refine ⟨13, 31, by norm_num, by norm_num, by norm_num, ?_, ?_⟩
  · rw [show (13 : ℕ) ^ 2 = 169 from by norm_num, pellRank_onesixtynine, pellRank_thirteen]
  · rw [show (31 : ℕ) ^ 2 = 961 from by norm_num, pellRank_thirtyone_sq, pellRank_thirtyone]

end Catalog.Novelty.PellSpine