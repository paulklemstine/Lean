            ## Research Task: Carmichael's Theorem: Primitive Prime Divisors for Composite-Index Fibonacci Numbers

            Research Mode: SORRY_FILL

You are given Lean 4 files that contain `sorry` placeholders.
Your task is CRITICALLY IMPORTANT: fill ALL `sorry` placeholders
with complete, rigorous proofs. This closes known open problems.

Strategy:
1. READ the surrounding context — theorem statements and imports are hints
2. DO NOT change theorem statements — only fill the `sorry`
3. Break hard proofs into helper lemmas first
4. A proof with fewer sorries is better than one that doesn't compile


            ### Research Direction
            Close the remaining sorry on fib_composite_has_primitive by proving that every Fibonacci number F_n with composite index n > 12 admits a primitive prime divisor (a prime p dividing F_n but dividing no F_k for k < n). The proof bridges the existing native_decide verification for n ∈ [13,10000] to the infinite composite case by combining entry-point theory (fibEntryPt_dvd_of_fib_dvd, primitive_of_entryPt_eq), exponential growth bounds (fib_exp_bound, fib_primitive_divisor_existence), and a lifting-the-exponent lemma for Fibonacci numbers to control p-adic valuations in the stripping algorithm (stripAllAux, primPart).

            ### Precise Mathematical Framing
            This is the composite-index case of the Bang–Zsigmondy theorem for the Fibonacci sequence. For n composite, every prime divisor p of F_n has an entry point (rank of apparition) z(p) dividing n. If no primitive divisor exists, every p dividing F_n satisfies z(p) | d for some proper divisor d | n, implying p | ∏_{d|n, d<n} F_d. The theorem follows by showing F_n exceeds this product in magnitude for n > 12 (using fib_linear_lower and fib_exp_bound), while the catalog lemmas fibEntryPt_pos and fib_dvd_gcd_of_dvd govern the divisibility lattice. The remaining gap in Shared/CarmichaelProof.lean is the inductive bridge that transports the finite computational verification to the infinite algebraic descent.

            ### Lean 4 Sketch
fib_composite_has_primitive

            ### Existing Verified Theorems to Build On
            Existing theorems you can build on:
  1. `fib_primitive_divisor_prime` : theorem fib_primitive_divisor_prime (n : ℕ) (hn : 13 ≤ n) (hnp : Nat.Prime n) :
     (file: Shared/CarmichaelHelper.lean)
  2. `fib_primitive_divisor_prime` : theorem fib_primitive_divisor_prime (n : ℕ) (hn : 13 ≤ n) (hnp : Nat.Prime n) :
     (file: Shared/Shared/CarmichaelHelper.lean)
  3. `entry_point_divides` : lemma entry_point_divides (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n) (hpn : p ∣ Nat.fib n)
     (file: Shared/CarmichaelComputational.lean)
  4. `primPart_implies_primitive` : lemma primPart_implies_primitive (n : ℕ) (hn : 3 ≤ n) (hpp : 1 < primPart n) :
     (file: Shared/CarmichaelProof.lean)
  5. `fib_primitive_divisor_existence` : theorem fib_primitive_divisor_existence :
     (file: Shared/Fib_gcd_identity.lean)

            Known Working Lean 4 Tactics:
- `nlinarith [sq_nonneg X]` for quadratic inequalities
- `positivity` for positivity goals
- `field_simp` then `ring` for division
- `Real.exp_le_exp.mpr` for exp monotonicity
- `Real.log_le_log` for log inequalities
- `div_pos`, `div_le_div_of_nonneg_left` for division inequalities
- `pow_le_pow_right₀` for power monotonicity
- `by decide` / `by norm_num` / `native_decide` for decidable propositions
- `Subadditive.tendsto_lim` for Fekete's Lemma
- `ConvexOn.map_sum_le` for Jensen's inequality
- `exists_deriv_eq_slope` for MVT




            ### Previously Proved Theorems
No previous research cycles completed yet. This is a cold start — prioritize sorry_fill on the priority targets (CarmichaelComposite, Fib_gcd_identity) to close known open problems, or target cross-domain bridge theorems for novelty.

            ### Required Deliverables

            You are a world-class mathematician and software engineer. Create:

            1. **Lean 4 files** — formally verified theorems with complete proofs
               - Use concrete types (ℕ, ℝ, Finset, Matrix, etc.)
               - Build on the existing catalog theorems listed above
               - Minimize `sorry` — isolate hard steps rather than leaving gaps
               - Use doc comments to explain the significance of key results

            2. **RESEARCH_REPORT.md** — paper explaining the discovery
               - Mathematical significance and connections to existing work
               - A Scientific American style discussion section
               - Detailed proofs and explanations

            3. **FUTURE_DIRECTIONS.md** — YOUR recommendations for what to research next
               - Specific theorems or conjectures worth pursuing
               - Which existing catalog results could be extended and how
               - Cross-domain connections you noticed during this research
               - Open problems you encountered but couldn't solve
               - This report will guide the next research cycle

            4. **demo.py** — Python demo with concrete numerical examples
               - Working code that brings the math to life
               - Visualizations where they add insight

            5. **diagram.svg** — visualization of key mathematical structures

            The mathematics comes FIRST. Excellent proofs trump everything else.
            Fill existing `sorry` placeholders — do not change theorem statements.

            ### Catalog Reference Files
            @Shared/CarmichaelProof.lean
```lean
import Mathlib
import Shared.CarmichaelHelper

/-! # Complete proof of Carmichael's theorem (composite case)

We prove that for composite n ≥ 13, F(n) has a primitive prime divisor.
-/

set_option maxHeartbeats 800000

/-! ## Bridge Lemma -/

lemma bridge_lemma (n : ℕ) (hn : 0 < n) (p : ℕ)
    (hpn : p ∣ Nat.fib n)
    (hdiv : ∀ d, d ∣ n → 0 < d → d < n → ¬(p ∣ Nat.fib d)) :
    ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  intro k hk hkn hpk
  have h_gcd_dvd : p ∣ Nat.fib (Nat.gcd n k) := by
    rw [Nat.fib_gcd]; exact Nat.dvd_gcd hpn hpk
  exact hdiv (Nat.gcd n k) (Nat.gcd_dvd_left n k)
    (Nat.gcd_pos_of_pos_left k hn)
    (lt_of_le_of_lt (Nat.gcd_le_right n hk) hkn) h_gcd_dvd

/-! ## Computational verification infrastructure -/

/-- Strip all factors of m from r, with bounded fuel -/
def stripAllAux (r : ℕ) (m : ℕ) : ℕ → ℕ
  | 0 => r
  | fuel + 1 =>
    if m ≤ 1 then r
    else
      let g := Nat.gcd r m
      if g ≤ 1 then r
      else stripAllAux (r / g) m fuel

/-- List of proper divisors of n (d with 0 < d < n and d | n) -/
def propDivs (n : ℕ) : List ℕ :=
  (List.range n).filter fun d => 0 < d && d < n && n % d == 0

/-- The primitive part of F(n) -/
def primPart (n : ℕ) : ℕ :=
  let fn := Nat.fib n
  (propDivs n).foldl (fun r d => stripAllAux r (Nat.fib d) r) fn

/-! ## Correctness lemmas -/

lemma stripAllAux_dvd (r m fuel : ℕ) : stripAllAux r m fuel ∣ r := by
  induction fuel generalizing r with
  | zero => exact dvd_refl r
  | succ fuel ih =>
    simp only [stripAllAux]
    split_ifs with h1 h2
    · exact dvd_refl r
    · exact dvd_refl r
    · exact dvd_trans (ih (r / Nat.gcd r m)) (Nat.div_dvd_of_dvd (Nat.gcd_dvd_left r m))

lemma stripAllAux_coprime (r m fuel : ℕ) (hm : 1 < m) (hr : 0 < r) (hfuel : r ≤ fuel) :
    Nat.gcd (stripAllAux r m fuel) m = 1 := by
  induction' fuel with fuel ih generalizing r m;
  · grind +qlia;
  · by_cases hgr : Nat.gcd r m > 1;
    · convert ih ( r / Nat.gcd r m ) m hm ( Nat.div_pos ( Nat.le_of_dvd hr ( Nat.gcd_dvd_left _ _ ) ) hgr.le ) _ using 1;
      · grind +locals;
      · exact Nat.le_of_lt_succ ( Nat.div_lt_of_lt_mul <| by nlinarith [ Nat.div_mul_cancel ( Nat.gcd_dvd_left r m ) ] );
    · interval_cases _ : Nat.gcd r m <;> simp_all +decide [ stripAllAux ]

lemma primPart_dvd (n : ℕ) : primPart n ∣ Nat.fib n := by
  simp [primPart];
  induction' ( propDivs n ) using List.reverseRecOn with d l ih <;> simp_all +decide [ List.foldl ];
  exact dvd_trans ( stripAllAux_dvd _ _ _ ) ih

lemma primPart_coprime_proper_divs (n : ℕ) (hpp : 1 < primPart n) (d : ℕ)
    (hd : d ∈ propDivs n) : ¬((primPart n).minFac ∣ Nat.fib d) := by
  have h_coprime : Nat.gcd (primPart n) (Nat.fib d) = 1 := by
    have h_coprime : ∀ l : List ℕ, d ∈ l → Nat.gcd (List.foldl (fun r d => stripAllAux r (Nat.fib d) r) (Nat.fib n) l) (Nat.fib d) = 1 := by
      intros l hl; induction' l using List.reverseRecOn with l ih <;> simp_all +decide [ Nat.gcd_comm ] ;
      by_cases h : Nat.fib ih > 1 <;> by_cases h' : 0 < List.foldl ( fun r d => stripAllAux r ( Nat.fib d ) r ) ( Nat.fib n ) l <;> simp_all +decide [ Nat.gcd_comm ];
      · have := stripAllAux_coprime ( List.foldl ( fun r d => stripAllAux r ( Nat.fib d ) r ) ( Nat.fib n ) l ) ( Nat.fib ih ) ( List.foldl ( fun r d => stripAllAux r ( Nat.fib d ) r ) ( Nat.fib n ) l ) h h' ( by linarith ) ; simp_all +decide [ Nat.gcd_comm ] ;
        cases hl <;> simp_all +decide [ Nat.gcd_comm ];
        exact Nat.Coprime.coprime_dvd_right ( stripAllAux_dvd _ _ _ ) ‹_›;
      · have h_contra : ∀ l : List ℕ, List.foldl (fun r d => stripAllAux r (Nat.fib d) r) (Nat.fib n) l = 0 → False := by
          intros l hl; induction' l using List.reverseRecOn with l ih <;> simp_all +decide [ Nat.gcd_comm ] ;
          have := stripAllAux_dvd ( List.foldl ( fun r d => stripAllAux r ( Nat.fib d ) r ) ( Nat.fib n ) l ) ( Nat.fib ih ) ( List.foldl ( fun r d => stripAllAux r ( Nat.fib d ) r ) ( Nat.fib n ) l ) ; simp_all +decide [ Nat.gcd_comm ] ;
        exact False.elim <| h_contra l h';
      · rcases ih with ( _ | _ | ih ) <;> simp_all +arith +decide [ Nat.fib_add_two ];
        · cases hl <;> simp_all +decide [ propDivs ];
          unfold stripAllAux; aesop;
        · unfold stripAllAux; aesop;
        · rcases ih with ( _ | _ | ih ) <;> simp_all +arith +decide [ Nat.fib_add_two ];
          · unfold stripAllAux; aesop;
          · linarith [ Nat.fib_pos.2 ( Nat.succ_pos ih ) ];
      · have h_contra : List.foldl (fun r d => stripAllAux r (Nat.fib d) r) (Nat.fib n) l ∣ Nat.fib n := by
          have h_contra : ∀ l : List ℕ, List.foldl (fun r d => stripAllAux r (Nat.fib d) r) (Nat.fib n) l ∣ Nat.fib n := by
            intro l; induction' l using List.reverseRecOn with l ih <;> simp_all +decide [ Nat.gcd_comm ] ;
            exact dvd_trans ( stripAllAux_dvd _ _ _ ) ‹_›;
          exact h_contra l;
        rcases n with ( _ | _ | n ) <;> simp_all +decide [ Nat.fib_add_two ];
    exact h_coprime _ hd;
  exact fun h => Nat.Prime.not_dvd_one ( Nat.minFac_prime hpp.ne' ) ( h_coprime ▸ Nat.dvd_gcd ( Nat.minFac_dvd _ ) h )

lemma primPart_implies_primitive (n : ℕ) (hn : 3 ≤ n) (hpp : 1 < primPart n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  have h_div : primPart n ∣ Nat.fib n := primPart_dvd n
  refine' ⟨ Nat.minFac ( primPart n ), Nat.minFac_prime hpp.ne', dvd_trans ( Nat.minFac_dvd _ ) h_div, _ ⟩;
  intro k hk hk';
  by_cases h_div_k : Nat.minFac (primPart n) ∣ Nat.fib (Nat.gcd k n);
  · have h_div_k : Nat.gcd k n ∈ propDivs n := by
      simp +decide [ propDivs ];
      exact ⟨ lt_of_le_of_lt ( Nat.le_of_dvd hk ( Nat.gcd_dvd_left _ _ ) ) hk', ⟨ Or.inl hk, lt_of_le_of_lt ( Nat.le_of_dvd hk ( Nat.gcd_dvd_left _ _ ) ) hk' ⟩, Nat.mod_eq_zero_of_dvd ( Nat.gcd_dvd_right _ _ ) ⟩;
    exact absurd ( primPart_coprime_proper_divs n hpp _ h_div_k ) ( by aesop );
  · exact fun h => h_div_k <| Nat.dvd_gcd h ( Nat.dvd_trans ( Nat.minFac_dvd _ ) h_div ) |> fun x => by simpa [ Nat.fib_gcd ] using x;

/-! ## Computational verification -/

/-- Verified: for all n ∈ [13, 10000], either n is prime or primPart n > 1 -/
theorem primPart_check : ∀ n ∈ Finset.Icc 13 10000, Nat.Prime n ∨ 1 < primPart n := by
  native_decide

/-! ## The composite case -/

theorem fib_carmichael_composite (n : ℕ) (hn : 13 ≤ n) (hnp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  by_cases h : n ≤ 10000
  · -- Finite case: extract from computational verification
    have := primPart_check n (Finset.mem_Icc.mpr ⟨hn, h⟩)
    exact primPart_implies_primitive n (by omega) (this.resolve_left hnp)
  · -- Infinite tail: composite n > 10000
    sorry

```

@Shared/CarmichaelComputational.lean
```lean
import Mathlib
import Shared.CarmichaelHelper
import Shared.CarmichaelProof

/-! # Computational verification of Carmichael's theorem

We verify Carmichael's primitive divisor theorem for composite n
using a combination of computation and mathematical argument.

Key approach:
- For composite n, every prime factor p of F(n) has an entry point α(p) | n
- If α(p) = n, then p is primitive
- The entry point divides n because gcd(F(n), F(k)) = F(gcd(n,k))
- For composite n, we show that the "primitive part" F*(n) = F(n) / gcd(F(n), lcm{F(d) : d|n, d<n}) > 1

We prove key structural lemmas and then apply them.
-/

set_option maxHeartbeats 800000

/-- If p | F(n) and p | F(k), then p | F(gcd(n,k)). -/
lemma fib_dvd_gcd (p n k : ℕ) (hn : p ∣ Nat.fib n) (hk : p ∣ Nat.fib k) :
    p ∣ Nat.fib (Nat.gcd n k) :=
  (Nat.fib_gcd n k) ▸ (Nat.dvd_gcd hn hk)

/-- The entry point of a prime p (smallest positive k with p | F(k)) divides any n with p | F(n).
    This is because gcd(n, α(p)) must equal α(p) by minimality. -/
lemma entry_point_divides (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n) (hpn : p ∣ Nat.fib n)
    (α : ℕ) (hα_pos : 0 < α) (hα_dvd : p ∣ Nat.fib α)
    (hα_min : ∀ m, 0 < m → m < α → ¬(p ∣ Nat.fib m)) :
    α ∣ n := by
  have h_gcd_le : Nat.gcd n α ≤ α := Nat.gcd_le_right n hα_pos
  have h_gcd_pos : 0 < Nat.gcd n α := Nat.gcd_pos_of_pos_left α hn
  have h_gcd_dvd : p ∣ Nat.fib (Nat.gcd n α) := fib_dvd_gcd p n α hpn hα_dvd
  have h_gcd_eq : Nat.gcd n α = α := by
    by_contra h_ne
    have h_lt : Nat.gcd n α < α := lt_of_le_of_ne h_gcd_le h_ne
    exact hα_min (Nat.gcd n α) h_gcd_pos h_lt h_gcd_dvd
  exact h_gcd_eq ▸ Nat.gcd_dvd_left n α

/-- For composite n, if ALL prime factors of F(n) have entry point < n,
    then each divides F(d) for some proper divisor d of n. -/
lemma all_factors_from_divisors (n : ℕ) (hn : 3 ≤ n) (hn_comp : ¬Nat.Prime n)
    (h_no_prim : ∀ p, Nat.Prime p → p ∣ Nat.fib n →
      ∃ k, 0 < k ∧ k < n ∧ p ∣ Nat.fib k) :
    ∀ p, Nat.Prime p → p ∣ Nat.fib n →
      ∃ d, d ∣ n ∧ 0 < d ∧ d < n ∧ p ∣ Nat.fib d := by
  intro p hp hpn
  obtain ⟨k, hk_pos, hk_lt, hpk⟩ := h_no_prim p hp hpn
  exact ⟨Nat.gcd n k,
    Nat.gcd_dvd_left n k,
    Nat.gcd_pos_of_pos_left k (by linarith),
    lt_of_le_of_lt (Nat.gcd_le_right n hk_pos) hk_lt,
    fib_dvd_gcd p n k hpn hpk⟩

/-- F(n) > 1 for n ≥ 3. -/
lemma fib_gt_one' (n : ℕ) (hn : 3 ≤ n) : 1 < Nat.fib n := by
  exact lt_of_lt_of_le (by decide) (Nat.fib_mono hn)

/-- For the composite case of Carmichael's theorem:
    If n is composite with n ≥ 13 and has a prime factor p,
    then either p is primitive for F(n), or the entry point of p
    strictly divides n (so p divides F(d) for proper d | n).

    This is the composite case, which together with `fib_primitive_divisor_prime`
    completes Carmichael's theorem. The proof requires deep number-theoretic
    infrastructure (lifting-the-exponent for Fibonacci, entry point theory).
    Currently an open formalization challenge. -/
theorem fib_composite_has_primitive (n : ℕ) (hn : 13 ≤ n) (hn_comp : ¬Nat.Prime n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  exact fib_carmichael_composite n hn hn_comp

```

@Speculative/AutoResearch/CarmichaelComposite.lean
```lean
import Mathlib
import Shared.CarmichaelHelper

/-! # Carmichael's theorem for composite n

We prove that for composite n ≥ 14, F(n) has a primitive prime divisor.

Key idea: We use entry point theory combined with a computational verification
of the "coprime part" of F(n) with respect to F(d) for proper divisors d | n.

The coprime part removes all prime factors of F(d) from F(n). If the result is > 1,
there exists a prime factor of F(n) coprime to all F(d), which by entry point theory
must be a primitive prime divisor.
-/

open Classical in
/-- The "Fibonacci entry point" of p: smallest k > 0 with p | F(k), or 0 if none. -/
noncomputable def fibEntryPt (p : ℕ) : ℕ :=
  if h : ∃ k, 0 < k ∧ p ∣ Nat.fib k then
    Nat.find h
  else 0

/-
If p | F(n) and p | F(k), then p | F(gcd(n,k)).
-/
lemma fib_dvd_gcd_of_dvd (p n k : ℕ) (hn : p ∣ Nat.fib n) (hk : p ∣ Nat.fib k) :
    p ∣ Nat.fib (Nat.gcd n k) := by
  exact Nat.dvd_gcd hn hk |> fun h => by simpa [ Nat.fib_gcd ] using h;

/-
The entry point divides n whenever p | F(n) and n > 0.
-/
lemma fibEntryPt_dvd_of_fib_dvd (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
    (hpn : p ∣ Nat.fib n) : fibEntryPt p ∣ n := by
  set α := fibEntryPt p
  have hα_pos : 0 < α := by
    unfold α fibEntryPt;
    split_ifs <;> simp_all +decide [ Nat.find_eq_iff ]
  have hα_div : p ∣ Nat.fib α := by
    simp +zetaDelta at *;
    unfold fibEntryPt at *;
    split_ifs at * <;> simp_all +decide [ Nat.find_spec ( _ : ∃ k, 0 < k ∧ p ∣ Nat.fib k ) ]
  have hα_min : ∀ m, 0 < m → m < α → ¬(p ∣ Nat.fib m) := by
    simp +zetaDelta at *;
    unfold fibEntryPt at *; aesop;
  have h_gcd_eq : Nat.gcd n α = α := by
    exact le_antisymm ( Nat.le_of_dvd hα_pos ( Nat.gcd_dvd_right _ _ ) ) ( Nat.le_of_not_gt fun h => hα_min _ ( Nat.gcd_pos_of_pos_left _ hn ) h <| fib_dvd_gcd_of_dvd _ _ _ hpn hα_div );
  exact h_gcd_eq ▸ Nat.gcd_dvd_left _ _

/-
Entry point is positive for any prime p | F(n) with n > 0.
-/
lemma fibEntryPt_pos (p : ℕ) (hp : Nat.Prime p) (hn : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
    0 < fibEntryPt p := by
  unfold fibEntryPt; aesop;

/-
If the entry point of p equals n, then p is a primitive prime divisor of F(n).
-/
lemma primitive_of_entryPt_eq (p n : ℕ) (hp : Nat.Prime p) (hpn : p ∣ Nat.fib n)
    (heq : fibEntryPt p = n) (hn : 0 < n) :
    ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  intro k hk hk' hk''; have := fibEntryPt_dvd_of_fib_dvd p k ( by assumption ) ( by linarith ) hk''; simp_all +decide [ Nat.dvd_iff_mod_eq_zero ] ;
  rw [ Nat.mod_eq_of_lt ] at this <;> linarith

/-! ## Computational infrastructure for primitive divisor verification -/

/-- Remove all prime factors of b from a. -/
def removePrimesOf (a b : ℕ) : ℕ :=
  if ha : a = 0 then 0
  else
    let g := Nat.gcd a b
    if hg : g ≤ 1 then a
    else
      have : a / g < a := Nat.div_lt_self (Nat.pos_of_ne_zero ha) (by omega)
      removePrimesOf (a / g) b
termination_by a

/-- The coprime part of F(n) with respect to F(d) for all proper divisors d | n.
    If this is > 1, F(n) has a prime factor not appearing in any F(d) for proper d | n. -/
def fibCoprimePart (n : ℕ) : ℕ :=
  let fn := Nat.fib n
  let properDivs := (List.range n).filter (fun d => 0 < d && n % d == 0)
  properDivs.foldl (fun acc d => removePrimesOf acc (Nat.fib d)) fn

/-
removePrimesOf a b divides a.
-/
lemma removePrimesOf_dvd (a b : ℕ) : removePrimesOf a b ∣ a := by
  induction' a using Nat.strong_induction_on with a ih generalizing b;
  unfold removePrimesOf;
  split_ifs <;> simp_all +decide [ Nat.div_dvd_of_dvd ];
  split_ifs;
  · norm_num;
  · exact dvd_trans ( ih _ ( Nat.div_lt_self ( Nat.pos_of_ne_zero ‹_› ) ( lt_of_not_ge ‹_› ) ) _ ) ( Nat.div_dvd_of_dvd ( Nat.gcd_dvd_left _ _ ) )

/-
removePrimesOf a b is coprime to b when a > 0.
-/
lemma removePrimesOf_coprime (a b : ℕ) (ha : 0 < a) :
    Nat.Coprime (removePrimesOf a b) b := by
  induction' a using Nat.strong_induction_on with a ih generalizing b;
  unfold removePrimesOf;
  split_ifs <;> simp_all +decide [ Nat.Coprime, Nat.gcd_comm ];
  split_ifs;
  · exact Nat.Coprime.symm ( Nat.le_antisymm ‹_› ( Nat.gcd_pos_of_pos_left _ ha ) );
  · exact ih _ ( Nat.div_lt_self ha ( lt_of_not_ge ‹_› ) ) _ ( Nat.div_pos ( Nat.le_of_dvd ha ( Nat.gcd_dvd_left _ _ ) ) ( Nat.gcd_pos_of_pos_left _ ha ) )

/-
If p | F(n) and p doesn't divide F(d) for any proper divisor d of n,
    then p is a primitive prime divisor of F(n).
-/
lemma primitive_of_not_dvd_proper_divisors (p n : ℕ) (hp : Nat.Prime p)
    (hn : 0 < n) (hpn : p ∣ Nat.fib n)
    (hnd : ∀ d, d ∣ n → 0 < d → d < n → ¬(p ∣ Nat.fib d)) :
    ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  intro k hk hk'; specialize hnd ( Nat.gcd n k ) ; simp_all +decide [ Nat.gcd_pos_of_pos_right ] ;
  exact fun h => hnd ( Nat.gcd_dvd_left _ _ ) ( Nat.lt_of_le_of_lt ( Nat.le_of_dvd hk ( Nat.gcd_dvd_right _ _ ) ) hk' ) ( fib_dvd_gcd_of_dvd p n k hpn h )

/-
If fibCoprimePart n > 1, then F(n) has a primitive prime divisor.
-/
lemma primitive_of_fibCoprimePart_pos (n : ℕ) (hn : 0 < n)
    (hcp : 1 < fibCoprimePart n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  -- By definition of `fibCoprimePart`, it is coprime to `fib d` for each proper divisor `d | n`.
  have h_coprime : ∀ d, d ∣ n → 0 < d → d < n → Nat.Coprime (fibCoprimePart n) (Nat.fib d) := by
    intros d hd hdn hdn';
    have h_fold_coprime : ∀ (ds : List ℕ), d ∈ ds → Nat.Coprime (List.foldl (fun acc d => removePrimesOf acc (Nat.fib d)) (Nat.fib n) ds) (Nat.fib d) := by
      intros ds hds;
      induction' ds using List.reverseRecOn with ds ih <;> simp_all +decide [ Nat.coprime_mul_iff_left, Nat.coprime_mul_iff_right ];
      by_cases h : d ∈ ds <;> simp_all +decide [ Nat.Coprime ];
      · refine' Nat.Coprime.coprime_dvd_left ( removePrimesOf_dvd _ _ ) ‹_›;
      · apply removePrimesOf_coprime;
        induction' ds using List.reverseRecOn with ds ih <;> simp_all +decide [ Nat.fib_pos ];
        exact Nat.pos_of_dvd_of_pos ( removePrimesOf_dvd _ _ ) ‹_›;
    apply h_fold_coprime;
    simp +decide [ List.mem_filter, List.mem_range, hdn, hdn', Nat.dvd_iff_mod_eq_zero.mp hd ];
  -- Let `p` be a prime factor of `fibCoprimePart n`.
  obtain ⟨p, hp_prime, hp_dvd⟩ : ∃ p, Nat.Prime p ∧ p ∣ fibCoprimePart n := by
    exact Nat.exists_prime_and_dvd hcp.ne';
  -- Since `p` divides `fibCoprimePart n`, it follows that `p` divides `Nat.fib n`.
  have hp_dvd_fib : p ∣ Nat.fib n := by
    refine dvd_trans hp_dvd ?_;
    unfold fibCoprimePart;
    induction' ( List.filter ( fun d => decide ( 0 < d ) && n % d == 0 ) ( List.range n ) ) using List.reverseRecOn with d l ih <;> simp_all +decide [ Nat.dvd_trans ];
    exact dvd_trans ( removePrimesOf_dvd _ _ ) ih;
  refine' ⟨ p, hp_prime, hp_dvd_fib, fun k hk₁ hk₂ hk₃ => _ ⟩;
  contrapose! h_coprime;
  refine' ⟨ Nat.gcd n k, Nat.gcd_dvd_left _ _, Nat.gcd_pos_of_pos_left _ hn, _, _ ⟩;
-- ... (truncated, full file has 181 lines)
```

@Speculative/AutoResearch/CarmichaelPrimitiveDivisor.lean
```lean
import Mathlib

/-! # Carmichael's Primitive Divisor Theorem for Fibonacci Numbers

For n ≥ 13, F(n) has a primitive prime divisor: a prime p such that
p | F(n) but p ∤ F(k) for all 0 < k < n.
-/

set_option maxHeartbeats 800000

/-- If p | F(n) and p | F(k), then p | F(gcd(n,k)). -/
lemma fib_prime_dvd_gcd' (p n k : ℕ) (hpn : p ∣ Nat.fib n) (hpk : p ∣ Nat.fib k) :
    p ∣ Nat.fib (Nat.gcd n k) := by
  exact Nat.fib_gcd n k ▸ Nat.dvd_gcd hpn hpk

/-- F(n) > 1 for n ≥ 3. -/
lemma fib_gt_one (n : ℕ) (hn : 3 ≤ n) : 1 < Nat.fib n := by
  match n, hn with
  | 3, _ => decide
  | n + 4, _ =>
    have := @Nat.fib_add_two (n + 2)
    have := Nat.fib_pos.mpr (show 0 < n + 3 by omega)
    have := Nat.fib_pos.mpr (show 0 < n + 2 by omega)
    linarith

/-- F(n) has a prime factor for n ≥ 3. -/
lemma fib_has_prime_factor' (n : ℕ) (hn : 3 ≤ n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n := by
  have := fib_gt_one n hn
  exact ⟨Nat.minFac (Nat.fib n), Nat.minFac_prime (by omega), Nat.minFac_dvd _⟩

/-- If p is a prime factor of F(n) that is NOT primitive, then p | F(d)
    for some d with d | n and 0 < d < n. -/
lemma non_primitive_to_proper_divisor (p n : ℕ) (_hp : Nat.Prime p)
    (hpn : p ∣ Nat.fib n) (hn : 0 < n)
    (k : ℕ) (hk_pos : 0 < k) (hk_lt : k < n) (hpk : p ∣ Nat.fib k) :
    ∃ d, 0 < d ∧ d ∣ n ∧ d < n ∧ p ∣ Nat.fib d := by
  refine ⟨Nat.gcd n k, ?_, Nat.gcd_dvd_left n k, ?_, fib_prime_dvd_gcd' p n k hpn hpk⟩
  · exact Nat.pos_of_ne_zero (by intro h; simp [Nat.gcd_eq_zero_iff] at h; omega)
  · calc Nat.gcd n k ≤ k := Nat.gcd_le_right n hk_pos
    _ < n := hk_lt

/-- Carmichael's theorem: For n ≥ 13, F(n) has a primitive prime divisor. -/
theorem fib_primitive_divisor (n : ℕ) (hn : 13 ≤ n) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  sorry

```

@Speculative/AutoResearch/Fib_gcd_identity.lean
```lean
import Mathlib
import Speculative.PisanoPeriodFactoring

/-! # CatalogBuild.Shared.Fib_gcd_identity

Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 8
-/

/-- GCD identity: gcd(F(m), F(n)) = F(gcd(m,n)). -/
theorem fib_gcd_identity (m n : ℕ) :
    Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n) :=
  (Nat.fib_gcd m n).symm




/-- Fibonacci divisibility: m | n implies F(m) | F(n). -/
theorem fib_dvd_chain (m n : ℕ) (h : m ∣ n) : Nat.fib m ∣ Nat.fib n :=
  Nat.fib_dvd _ _ h




/-- Carmichael's theorem (weak): For n ≥ 13, F(n) has a primitive prime divisor. -/
theorem fib_primitive_divisor_existence :
    ∀ n : ℕ, 13 ≤ n → ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  sorry



/-- [Section: # CatalogBuild.Shared.Fib_gcd_identity
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 8] -/
theorem fib_linear_lower (n : ℕ) (hn : 6 ≤ n) : n ≤ Nat.fib n := by
  rcases n with ( _ | _ | _ | _ | _ | _ | _ | n ) <;> simp_all +arith +decide;
  exact Nat.recOn n ( by decide ) fun n ihn => by norm_num [ Nat.fib_add_two ] at * ; linarith




/-- F(n) ≤ 2^n for all n. -/
theorem fib_exp_bound (n : ℕ) : Nat.fib n ≤ 2^n := by
  induction n using Nat.strongRecOn with
  | ind n ih =>
    match n with
    | 0 => simp
    | 1 => simp [Nat.fib]
    | n + 2 =>
      rw [Nat.fib_add_two]
      have h1 := ih (n+1) (by omega)
      have h2 := ih n (by omega)
      have : 2^n ≤ 2^(n+1) := Nat.pow_le_pow_right (by omega) (by omega)
      linarith [show 2^(n+2) = 2^(n+1) + 2^(n+1) from by ring]




/-- [Section: # CatalogBuild.Shared.Fib_gcd_identity
Auto-generated from theorem catalog database.
Domain: Shared
Declarations: 8] -/
theorem fib_sq_mod_prime (p : ℕ) (hp : Nat.Prime p) (hp2 : p ≠ 2) (hp5 : p ≠ 5) :
    (Nat.fib p ^ 2) % p = 1 % p := by
  haveI := Fact.mk hp; norm_num [ ← ZMod.natCast_eq_natCast_iff' ] ; ring_nf;
  -- By definition of Fibonacci sequence, we know that $F_p = \frac{(1 + \sqrt{5})^p - (1 - \sqrt{5})^p}{2^p \sqrt{5}}$.
  have h_fib_def : (Nat.fib p : ℤ) = ((1 + Real.sqrt 5) ^ p - (1 - Real.sqrt 5) ^ p) / (2 ^ p * Real.sqrt 5) := by
    have h_fib_def : ∀ n, (Nat.fib n : ℝ) = ((1 + Real.sqrt 5) ^ n - (1 - Real.sqrt 5) ^ n) / (2 ^ n * Real.sqrt 5) := by
      intro n; induction' n using Nat.strong_induction_on with n ih; rcases n with ( _ | _ | n ) <;> norm_num [ Nat.fib_add_two ] at *;
      · ring_nf; norm_num;
      · rw [ ih n ( by linarith ), ih ( n + 1 ) ( by linarith ) ] ; repeat ring <;> norm_num [ pow_succ' ] ;
    exact h_fib_def p ▸ by norm_num;
  -- Let's simplify the expression for $F_p$ modulo $p$.
  have h_fib_mod : ((1 + Real.sqrt 5) ^ p - (1 - Real.sqrt 5) ^ p) / (2 ^ p * Real.sqrt 5) = (∑ k ∈ Finset.range (p / 2 + 1), Nat.choose p (2 * k + 1) * 5 ^ k) / 2 ^ (p - 1) := by
    have h_binom : ((1 + Real.sqrt 5) ^ p - (1 - Real.sqrt 5) ^ p) = ∑ k ∈ Finset.range (p + 1), Nat.choose p k * Real.sqrt 5 ^ k * (if k % 2 = 1 then 2 else 0) := by
      have h_binom : ((1 + Real.sqrt 5) ^ p - (1 - Real.sqrt 5) ^ p) = ∑ k ∈ Finset.range (p + 1), Nat.choose p k * Real.sqrt 5 ^ k - ∑ k ∈ Finset.range (p + 1), Nat.choose p k * (-Real.sqrt 5) ^ k := by
        exact congrArg₂ _ ( by rw [ add_comm, add_pow ] ; simp +decide [ mul_comm ] ) ( by rw [ sub_eq_add_neg, add_comm, add_pow ] ; simp +decide [ mul_comm ] );
      rw [ h_binom, ← Finset.sum_sub_distrib ] ; refine' Finset.sum_congr rfl fun x hx => _ ; rcases Nat.even_or_odd' x with ⟨ k, rfl | rfl ⟩ <;> norm_num [ pow_add, pow_mul ] ; ring;
    -- Let's simplify the expression for $F_p$ modulo $p$ using the binomial theorem.
    have h_binom_simplified : ∑ k ∈ Finset.range (p + 1), Nat.choose p k * Real.sqrt 5 ^ k * (if k % 2 = 1 then 2 else 0) = 2 * ∑ k ∈ Finset.range ((p + 1) / 2), Nat.choose p (2 * k + 1) * Real.sqrt 5 ^ (2 * k + 1) := by
      have h_binom_simplified : Finset.filter (fun k => k % 2 = 1) (Finset.range (p + 1)) = Finset.image (fun k => 2 * k + 1) (Finset.range ((p + 1) / 2)) := by
        ext ( _ | k ) <;> simp +arith +decide [ Nat.add_mod, Nat.mul_mod ];
        exact ⟨ fun h => ⟨ k / 2, by omega, by omega ⟩, fun ⟨ a, ha, ha' ⟩ => ⟨ by omega, by omega ⟩ ⟩;
      simp_all +decide [ Finset.sum_ite, mul_comm, Finset.mul_sum _ _ _ ];
    rcases Nat.even_or_odd' p with ⟨ c, rfl | rfl ⟩ <;> norm_num [ Nat.add_div ] at *;
    · simp_all +decide [ Nat.prime_mul_iff ];
    · rw [ h_binom, h_binom_simplified ] ; ring_nf ; norm_num [ pow_add, pow_mul, mul_assoc, mul_left_comm, mul_comm ] ; ring;
      norm_num [ pow_mul', mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ];
  -- Let's simplify the expression for $F_p$ modulo $p$ further.
  have h_fib_mod_simplified : (∑ k ∈ Finset.range (p / 2 + 1), Nat.choose p (2 * k + 1) * 5 ^ k) ≡ 5 ^ ((p - 1) / 2) [ZMOD p] := by
    have h_fib_mod_simplified : ∀ k ∈ Finset.range (p / 2), Nat.choose p (2 * k + 1) ≡ 0 [ZMOD p] := by
      exact fun k hk => Int.modEq_zero_iff_dvd.mpr <| mod_cast hp.dvd_choose_self ( by linarith [ Finset.mem_range.mp hk ] ) ( by linarith [ Finset.mem_range.mp hk, Nat.div_mul_le_self p 2 ] ) ;
    rcases Nat.even_or_odd' p with ⟨ c, rfl | rfl ⟩ <;> norm_num at *;
    · simp_all +decide [ Nat.prime_mul_iff ];
    · norm_num [ Nat.add_div, Finset.sum_range_succ ] at *;
      exact Finset.dvd_sum fun i hi => dvd_mul_of_dvd_left ( Int.dvd_of_emod_eq_zero ( h_fib_mod_simplified i ( Finset.mem_range.mp hi ) ) ) _;
  -- Let's simplify the expression for $F_p$ modulo $p$ further using the fact that $2^{p-1} \equiv 1 \pmod{p}$.
  have h_fib_mod_final : (Nat.fib p : ℤ) * 2 ^ (p - 1) ≡ 5 ^ ((p - 1) / 2) [ZMOD p] := by
    convert h_fib_mod_simplified using 1;
    rw [ ← @Int.cast_inj ℝ ] ; aesop;
  have h_fermat : 2 ^ (p - 1) ≡ 1 [ZMOD p] ∧ 5 ^ (p - 1) ≡ 1 [ZMOD p] := by
    have := Nat.totient_prime hp; erw [ ← this ] ; exact ⟨ by simpa [ ← Int.natCast_modEq_iff ] using Nat.ModEq.pow_totient <| Nat.coprime_comm.mp <| hp.coprime_iff_not_dvd.mpr fun h => by have := Nat.le_of_dvd ( by decide ) h; interval_cases p <;> trivial, by simpa [ ← Int.natCast_modEq_iff ] using Nat.ModEq.pow_totient <| Nat.coprime_comm.mp <| hp.coprime_iff_not_dvd.mpr fun h => by have := Nat.le_of_dvd ( by decide ) h; interval_cases p <;> trivial ⟩ ;
  simp_all +decide [ ← ZMod.intCast_eq_intCast_iff ];
  exact eq_or_eq_neg_of_sq_eq_sq _ _ <| by rw [ ← pow_mul', Nat.mul_div_cancel' <| even_iff_two_dvd.mp <| hp.even_sub_one hp2 ] ; aesop;




theorem fib_composite_test (n : ℕ) (hn : 1 < n) (hn2 : n ≠ 2) (hn5 : n ≠ 5)
    (h : (Nat.fib n ^ 2) % n ≠ 1 % n) :
    ¬Nat.Prime n := by
  exact fun h' => h <| by have := fib_sq_mod_prime n h' hn2 hn5; simpa [ sq, Nat.mul_mod ] using this;




/-- F(4) = 3. -/
theorem fib_four_val : Nat.fib 4 = 3 := by native_decide




```


### WHAT WE NEED FROM YOU

You are a world-class mathematician and software engineer. Use your judgment
on the best way to organize and present your work. We need:

1. **Formally verified mathematics** in Lean 4
   - Prove non-trivial theorems with complete proofs (no `sorry` in the final result)
   - Organize the Lean code however makes sense — one file or several,
     whatever serves the mathematics best
   - Use doc comments to explain the significance of key results

2. **Python demos** that bring the mathematics to life
   - Create working Python code that demonstrates the theorems with
     concrete numerical examples
   - Visualizations (matplotlib, etc.) where they add insight
   - Show the math in action — make it tangible and understandable
   - Name and organize the demos however you see fit

3. **A research paper** that explains the discovery
   - Write this as a proper mathematical paper
   - Include a Scientific American style discussion section that makes
     the result accessible to a broad audience — use analogies,
     intuition, and historical context
   - Explain connections to existing work and future directions

4. **Useful applications** — show how this math matters in practice
   - What can people DO with this result?
   - Where does it apply in the real world?
   - Include code, examples, or demonstrations of applications

The mathematics comes FIRST. Excellent proofs trump everything else.
But great work deserves great presentation — make it real and useful.

Research domain: Shared
Research mode: sorry_fill
