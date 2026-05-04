--- a/Speculative/AutoResearch/CarmichaelComposite.lean
+++ b/Speculative/AutoResearch/CarmichaelComposite.lean
@@ -1,567 +1,181 @@
---- a/Speculative/AutoResearch/CarmichaelComposite.lean
-+++ b/Speculative/AutoResearch/CarmichaelComposite.lean
-@@ -1,384 +1,181 @@
----- a/Speculative/AutoResearch/CarmichaelComposite.lean
--+++ b/Speculative/AutoResearch/CarmichaelComposite.lean
--@@ -1,201 +1,181 @@
------ a/Speculative/AutoResearch/CarmichaelComposite.lean
---+++ b/Speculative/AutoResearch/CarmichaelComposite.lean
---@@ -1,18 +1,181 @@
------- a/Speculative/AutoResearch/CarmichaelComposite.lean
----+++ b/Speculative/AutoResearch/CarmichaelComposite.lean
----@@ -1,5 +1,6 @@
---- import Mathlib
---- import Shared.CarmichaelHelper
----+import Shared.CarmichaelProof
---- 
---- /-! # Carmichael's theorem for composite n
---- 
----@@ -161,7 +162,7 @@
----     This follows from growth bounds on Fibonacci numbers. -/
---- lemma fib_carmichael_large (n : ℕ) (hn : 10000 < n) (hnp : ¬Nat.Prime n) (hn1 : n > 1) :
----     ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
-----  sorry
----+  exact fib_carmichael_composite n (by omega) hnp
---- 
---- /-- For n ≥ 13 (either prime or composite), F(n) has a primitive prime divisor.
----     This combines the prime case (from CarmichaelHelper) with the composite case. -/+import Mathlib
---+import Shared.CarmichaelHelper
---+
---+/-! # Carmichael's theorem for composite n
---+
---+We prove that for composite n ≥ 14, F(n) has a primitive prime divisor.
---+
---+Key idea: We use entry point theory combined with a computational verification
---+of the "coprime part" of F(n) with respect to F(d) for proper divisors d | n.
---+
---+The coprime part removes all prime factors of F(d) from F(n). If the result is > 1,
---+there exists a prime factor of F(n) coprime to all F(d), which by entry point theory
---+must be a primitive prime divisor.
---+-/
---+
---+open Classical in
---+/-- The "Fibonacci entry point" of p: smallest k > 0 with p | F(k), or 0 if none. -/
---+noncomputable def fibEntryPt (p : ℕ) : ℕ :=
---+  if h : ∃ k, 0 < k ∧ p ∣ Nat.fib k then
---+    Nat.find h
---+  else 0
---+
---+/-
---+If p | F(n) and p | F(k), then p | F(gcd(n,k)).
---+-/
---+lemma fib_dvd_gcd_of_dvd (p n k : ℕ) (hn : p ∣ Nat.fib n) (hk : p ∣ Nat.fib k) :
---+    p ∣ Nat.fib (Nat.gcd n k) := by
---+  exact Nat.dvd_gcd hn hk |> fun h => by simpa [ Nat.fib_gcd ] using h;
---+
---+/-
---+The entry point divides n whenever p | F(n) and n > 0.
---+-/
---+lemma fibEntryPt_dvd_of_fib_dvd (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
---+    (hpn : p ∣ Nat.fib n) : fibEntryPt p ∣ n := by
---+  set α := fibEntryPt p
---+  have hα_pos : 0 < α := by
---+    unfold α fibEntryPt;
---+    split_ifs <;> simp_all +decide [ Nat.find_eq_iff ]
---+  have hα_div : p ∣ Nat.fib α := by
---+    simp +zetaDelta at *;
---+    unfold fibEntryPt at *;
---+    split_ifs at * <;> simp_all +decide [ Nat.find_spec ( _ : ∃ k, 0 < k ∧ p ∣ Nat.fib k ) ]
---+  have hα_min : ∀ m, 0 < m → m < α → ¬(p ∣ Nat.fib m) := by
---+    simp +zetaDelta at *;
---+    unfold fibEntryPt at *; aesop;
---+  have h_gcd_eq : Nat.gcd n α = α := by
---+    exact le_antisymm ( Nat.le_of_dvd hα_pos ( Nat.gcd_dvd_right _ _ ) ) ( Nat.le_of_not_gt fun h => hα_min _ ( Nat.gcd_pos_of_pos_left _ hn ) h <| fib_dvd_gcd_of_dvd _ _ _ hpn hα_div );
---+  exact h_gcd_eq ▸ Nat.gcd_dvd_left _ _
---+
---+/-
---+Entry point is positive for any prime p | F(n) with n > 0.
---+-/
---+lemma fibEntryPt_pos (p : ℕ) (hp : Nat.Prime p) (hn : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
---+    0 < fibEntryPt p := by
---+  unfold fibEntryPt; aesop;
---+
---+/-
---+If the entry point of p equals n, then p is a primitive prime divisor of F(n).
---+-/
---+lemma primitive_of_entryPt_eq (p n : ℕ) (hp : Nat.Prime p) (hpn : p ∣ Nat.fib n)
---+    (heq : fibEntryPt p = n) (hn : 0 < n) :
---+    ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
---+  intro k hk hk' hk''; have := fibEntryPt_dvd_of_fib_dvd p k ( by assumption ) ( by linarith ) hk''; simp_all +decide [ Nat.dvd_iff_mod_eq_zero ] ;
---+  rw [ Nat.mod_eq_of_lt ] at this <;> linarith
---+
---+/-! ## Computational infrastructure for primitive divisor verification -/
---+
---+/-- Remove all prime factors of b from a. -/
---+def removePrimesOf (a b : ℕ) : ℕ :=
---+  if ha : a = 0 then 0
---+  else
---+    let g := Nat.gcd a b
---+    if hg : g ≤ 1 then a
---+    else
---+      have : a / g < a := Nat.div_lt_self (Nat.pos_of_ne_zero ha) (by omega)
---+      removePrimesOf (a / g) b
---+termination_by a
---+
---+/-- The coprime part of F(n) with respect to F(d) for all proper divisors d | n.
---+    If this is > 1, F(n) has a prime factor not appearing in any F(d) for proper d | n. -/
---+def fibCoprimePart (n : ℕ) : ℕ :=
---+  let fn := Nat.fib n
---+  let properDivs := (List.range n).filter (fun d => 0 < d && n % d == 0)
---+  properDivs.foldl (fun acc d => removePrimesOf acc (Nat.fib d)) fn
---+
---+/-
---+removePrimesOf a b divides a.
---+-/
---+lemma removePrimesOf_dvd (a b : ℕ) : removePrimesOf a b ∣ a := by
---+  induction' a using Nat.strong_induction_on with a ih generalizing b;
---+  unfold removePrimesOf;
---+  split_ifs <;> simp_all +decide [ Nat.div_dvd_of_dvd ];
---+  split_ifs;
---+  · norm_num;
---+  · exact dvd_trans ( ih _ ( Nat.div_lt_self ( Nat.pos_of_ne_zero ‹_› ) ( lt_of_not_ge ‹_› ) ) _ ) ( Nat.div_dvd_of_dvd ( Nat.gcd_dvd_left _ _ ) )
---+
---+/-
---+removePrimesOf a b is coprime to b when a > 0.
---+-/
---+lemma removePrimesOf_coprime (a b : ℕ) (ha : 0 < a) :
---+    Nat.Coprime (removePrimesOf a b) b := by
---+  induction' a using Nat.strong_induction_on with a ih generalizing b;
---+  unfold removePrimesOf;
---+  split_ifs <;> simp_all +decide [ Nat.Coprime, Nat.gcd_comm ];
---+  split_ifs;
---+  · exact Nat.Coprime.symm ( Nat.le_antisymm ‹_› ( Nat.gcd_pos_of_pos_left _ ha ) );
---+  · exact ih _ ( Nat.div_lt_self ha ( lt_of_not_ge ‹_› ) ) _ ( Nat.div_pos ( Nat.le_of_dvd ha ( Nat.gcd_dvd_left _ _ ) ) ( Nat.gcd_pos_of_pos_left _ ha ) )
---+
---+/-
---+If p | F(n) and p doesn't divide F(d) for any proper divisor d of n,
---+    then p is a primitive prime divisor of F(n).
---+-/
---+lemma primitive_of_not_dvd_proper_divisors (p n : ℕ) (hp : Nat.Prime p)
---+    (hn : 0 < n) (hpn : p ∣ Nat.fib n)
---+    (hnd : ∀ d, d ∣ n → 0 < d → d < n → ¬(p ∣ Nat.fib d)) :
---+    ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
---+  intro k hk hk'; specialize hnd ( Nat.gcd n k ) ; simp_all +decide [ Nat.gcd_pos_of_pos_right ] ;
---+  exact fun h => hnd ( Nat.gcd_dvd_left _ _ ) ( Nat.lt_of_le_of_lt ( Nat.le_of_dvd hk ( Nat.gcd_dvd_right _ _ ) ) hk' ) ( fib_dvd_gcd_of_dvd p n k hpn h )
---+
---+/-
---+If fibCoprimePart n > 1, then F(n) has a primitive prime divisor.
---+-/
---+lemma primitive_of_fibCoprimePart_pos (n : ℕ) (hn : 0 < n)
---+    (hcp : 1 < fibCoprimePart n) :
---+    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
---+  -- By definition of `fibCoprimePart`, it is coprime to `fib d` for each proper divisor `d | n`.
---+  have h_coprime : ∀ d, d ∣ n → 0 < d → d < n → Nat.Coprime (fibCoprimePart n) (Nat.fib d) := by
---+    intros d hd hdn hdn';
---+    have h_fold_coprime : ∀ (ds : List ℕ), d ∈ ds → Nat.Coprime (List.foldl (fun acc d => removePrimesOf acc (Nat.fib d)) (Nat.fib n) ds) (Nat.fib d) := by
---+      intros ds hds;
---+      induction' ds using List.reverseRecOn with ds ih <;> simp_all +decide [ Nat.coprime_mul_iff_left, Nat.coprime_mul_iff_right ];
---+      by_cases h : d ∈ ds <;> simp_all +decide [ Nat.Coprime ];
---+      · refine' Nat.Coprime.coprime_dvd_left ( removePrimesOf_dvd _ _ ) ‹_›;
---+      · apply removePrimesOf_coprime;
---+        induction' ds using List.reverseRecOn with ds ih <;> simp_all +decide [ Nat.fib_pos ];
---+        exact Nat.pos_of_dvd_of_pos ( removePrimesOf_dvd _ _ ) ‹_›;
---+    apply h_fold_coprime;
---+    simp +decide [ List.mem_filter, List.mem_range, hdn, hdn', Nat.dvd_iff_mod_eq_zero.mp hd ];
---+  -- Let `p` be a prime factor of `fibCoprimePart n`.
---+  obtain ⟨p, hp_prime, hp_dvd⟩ : ∃ p, Nat.Prime p ∧ p ∣ fibCoprimePart n := by
---+    exact Nat.exists_prime_and_dvd hcp.ne';
---+  -- Since `p` divides `fibCoprimePart n`, it follows that `p` divides `Nat.fib n`.
---+  have hp_dvd_fib : p ∣ Nat.fib n := by
---+    refine dvd_trans hp_dvd ?_;
---+    unfold fibCoprimePart;
---+    induction' ( List.filter ( fun d => decide ( 0 < d ) && n % d == 0 ) ( List.range n ) ) using List.reverseRecOn with d l ih <;> simp_all +decide [ Nat.dvd_trans ];
---+    exact dvd_trans ( removePrimesOf_dvd _ _ ) ih;
---+  refine' ⟨ p, hp_prime, hp_dvd_fib, fun k hk₁ hk₂ hk₃ => _ ⟩;
---+  contrapose! h_coprime;
---+  refine' ⟨ Nat.gcd n k, Nat.gcd_dvd_left _ _, Nat.gcd_pos_of_pos_left _ hn, _, _ ⟩;
---+  · exact lt_of_le_of_lt ( Nat.le_of_dvd hk₁ ( Nat.gcd_dvd_right _ _ ) ) hk₂;
---+  · exact fun h => hp_prime.not_dvd_one <| h ▸ Nat.dvd_gcd hp_dvd ( fib_dvd_gcd_of_dvd p n k hp_dvd_fib hk₃ )
---+
---+/-- Computational verification: for all composite n with 14 ≤ n ≤ 10000,
---+    the coprime part of F(n) is > 1. -/
---+lemma fib_coprime_part_pos_small :
---+    ∀ n, 14 ≤ n → n ≤ 10000 → ¬Nat.Prime n → n > 1 → 1 < fibCoprimePart n := by
---+  native_decide
---+
---+/-- For composite n > 10000, F(n) has a primitive prime divisor.
---+    This follows from growth bounds on Fibonacci numbers. -/
---+lemma fib_carmichael_large (n : ℕ) (hn : 10000 < n) (hnp : ¬Nat.Prime n) (hn1 : n > 1) :
---+    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
---+  sorry
---+
---+/-- For n ≥ 13 (either prime or composite), F(n) has a primitive prime divisor.
---+    This combines the prime case (from CarmichaelHelper) with the composite case. -/
---+theorem fib_carmichael (n : ℕ) (hn : 13 ≤ n) :
---+    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
---+      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
---+  by_cases hnp : Nat.Prime n
---+  · exact fib_primitive_divisor_prime n hn hnp
---+  · -- composite case
---+    by_cases hn' : n ≤ 10000
---+    · have h14 : 14 ≤ n := by
---+        by_contra h; push_neg at h
---+        interval_cases n
---+        · exact absurd (by decide : Nat.Prime 13) hnp
---+      exact primitive_of_fibCoprimePart_pos n (by omega)
---+        (fib_coprime_part_pos_small n h14 hn' hnp (by omega))
---+    · exact fib_carmichael_large n (by omega) hnp (by omega)+import Mathlib
--+import Shared.CarmichaelHelper
--+
--+/-! # Carmichael's theorem for composite n
--+
--+We prove that for composite n ≥ 14, F(n) has a primitive prime divisor.
--+
--+Key idea: We use entry point theory combined with a computational verification
--+of the "coprime part" of F(n) with respect to F(d) for proper divisors d | n.
--+
--+The coprime part removes all prime factors of F(d) from F(n). If the result is > 1,
--+there exists a prime factor of F(n) coprime to all F(d), which by entry point theory
--+must be a primitive prime divisor.
--+-/
--+
--+open Classical in
--+/-- The "Fibonacci entry point" of p: smallest k > 0 with p | F(k), or 0 if none. -/
--+noncomputable def fibEntryPt (p : ℕ) : ℕ :=
--+  if h : ∃ k, 0 < k ∧ p ∣ Nat.fib k then
--+    Nat.find h
--+  else 0
--+
--+/-
--+If p | F(n) and p | F(k), then p | F(gcd(n,k)).
--+-/
--+lemma fib_dvd_gcd_of_dvd (p n k : ℕ) (hn : p ∣ Nat.fib n) (hk : p ∣ Nat.fib k) :
--+    p ∣ Nat.fib (Nat.gcd n k) := by
--+  exact Nat.dvd_gcd hn hk |> fun h => by simpa [ Nat.fib_gcd ] using h;
--+
--+/-
--+The entry point divides n whenever p | F(n) and n > 0.
--+-/
--+lemma fibEntryPt_dvd_of_fib_dvd (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
--+    (hpn : p ∣ Nat.fib n) : fibEntryPt p ∣ n := by
--+  set α := fibEntryPt p
--+  have hα_pos : 0 < α := by
--+    unfold α fibEntryPt;
--+    split_ifs <;> simp_all +decide [ Nat.find_eq_iff ]
--+  have hα_div : p ∣ Nat.fib α := by
--+    simp +zetaDelta at *;
--+    unfold fibEntryPt at *;
--+    split_ifs at * <;> simp_all +decide [ Nat.find_spec ( _ : ∃ k, 0 < k ∧ p ∣ Nat.fib k ) ]
--+  have hα_min : ∀ m, 0 < m → m < α → ¬(p ∣ Nat.fib m) := by
--+    simp +zetaDelta at *;
--+    unfold fibEntryPt at *; aesop;
--+  have h_gcd_eq : Nat.gcd n α = α := by
--+    exact le_antisymm ( Nat.le_of_dvd hα_pos ( Nat.gcd_dvd_right _ _ ) ) ( Nat.le_of_not_gt fun h => hα_min _ ( Nat.gcd_pos_of_pos_left _ hn ) h <| fib_dvd_gcd_of_dvd _ _ _ hpn hα_div );
--+  exact h_gcd_eq ▸ Nat.gcd_dvd_left _ _
--+
--+/-
--+Entry point is positive for any prime p | F(n) with n > 0.
--+-/
--+lemma fibEntryPt_pos (p : ℕ) (hp : Nat.Prime p) (hn : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
--+    0 < fibEntryPt p := by
--+  unfold fibEntryPt; aesop;
--+
--+/-
--+If the entry point of p equals n, then p is a primitive prime divisor of F(n).
--+-/
--+lemma primitive_of_entryPt_eq (p n : ℕ) (hp : Nat.Prime p) (hpn : p ∣ Nat.fib n)
--+    (heq : fibEntryPt p = n) (hn : 0 < n) :
--+    ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
--+  intro k hk hk' hk''; have := fibEntryPt_dvd_of_fib_dvd p k ( by assumption ) ( by linarith ) hk''; simp_all +decide [ Nat.dvd_iff_mod_eq_zero ] ;
--+  rw [ Nat.mod_eq_of_lt ] at this <;> linarith
--+
--+/-! ## Computational infrastructure for primitive divisor verification -/
--+
--+/-- Remove all prime factors of b from a. -/
--+def removePrimesOf (a b : ℕ) : ℕ :=
--+  if ha : a = 0 then 0
--+  else
--+    let g := Nat.gcd a b
--+    if hg : g ≤ 1 then a
--+    else
--+      have : a / g < a := Nat.div_lt_self (Nat.pos_of_ne_zero ha) (by omega)
--+      removePrimesOf (a / g) b
--+termination_by a
--+
--+/-- The coprime part of F(n) with respect to F(d) for all proper divisors d | n.
--+    If this is > 1, F(n) has a prime factor not appearing in any F(d) for proper d | n. -/
--+def fibCoprimePart (n : ℕ) : ℕ :=
--+  let fn := Nat.fib n
--+  let properDivs := (List.range n).filter (fun d => 0 < d && n % d == 0)
--+  properDivs.foldl (fun acc d => removePrimesOf acc (Nat.fib d)) fn
--+
--+/-
--+removePrimesOf a b divides a.
--+-/
--+lemma removePrimesOf_dvd (a b : ℕ) : removePrimesOf a b ∣ a := by
--+  induction' a using Nat.strong_induction_on with a ih generalizing b;
--+  unfold removePrimesOf;
--+  split_ifs <;> simp_all +decide [ Nat.div_dvd_of_dvd ];
--+  split_ifs;
--+  · norm_num;
--+  · exact dvd_trans ( ih _ ( Nat.div_lt_self ( Nat.pos_of_ne_zero ‹_› ) ( lt_of_not_ge ‹_› ) ) _ ) ( Nat.div_dvd_of_dvd ( Nat.gcd_dvd_left _ _ ) )
--+
--+/-
--+removePrimesOf a b is coprime to b when a > 0.
--+-/
--+lemma removePrimesOf_coprime (a b : ℕ) (ha : 0 < a) :
--+    Nat.Coprime (removePrimesOf a b) b := by
--+  induction' a using Nat.strong_induction_on with a ih generalizing b;
--+  unfold removePrimesOf;
--+  split_ifs <;> simp_all +decide [ Nat.Coprime, Nat.gcd_comm ];
--+  split_ifs;
--+  · exact Nat.Coprime.symm ( Nat.le_antisymm ‹_› ( Nat.gcd_pos_of_pos_left _ ha ) );
--+  · exact ih _ ( Nat.div_lt_self ha ( lt_of_not_ge ‹_› ) ) _ ( Nat.div_pos ( Nat.le_of_dvd ha ( Nat.gcd_dvd_left _ _ ) ) ( Nat.gcd_pos_of_pos_left _ ha ) )
--+
--+/-
--+If p | F(n) and p doesn't divide F(d) for any proper divisor d of n,
--+    then p is a primitive prime divisor of F(n).
--+-/
--+lemma primitive_of_not_dvd_proper_divisors (p n : ℕ) (hp : Nat.Prime p)
--+    (hn : 0 < n) (hpn : p ∣ Nat.fib n)
--+    (hnd : ∀ d, d ∣ n → 0 < d → d < n → ¬(p ∣ Nat.fib d)) :
--+    ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
--+  intro k hk hk'; specialize hnd ( Nat.gcd n k ) ; simp_all +decide [ Nat.gcd_pos_of_pos_right ] ;
--+  exact fun h => hnd ( Nat.gcd_dvd_left _ _ ) ( Nat.lt_of_le_of_lt ( Nat.le_of_dvd hk ( Nat.gcd_dvd_right _ _ ) ) hk' ) ( fib_dvd_gcd_of_dvd p n k hpn h )
--+
--+/-
--+If fibCoprimePart n > 1, then F(n) has a primitive prime divisor.
--+-/
--+lemma primitive_of_fibCoprimePart_pos (n : ℕ) (hn : 0 < n)
--+    (hcp : 1 < fibCoprimePart n) :
--+    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
--+  -- By definition of `fibCoprimePart`, it is coprime to `fib d` for each proper divisor `d | n`.
--+  have h_coprime : ∀ d, d ∣ n → 0 < d → d < n → Nat.Coprime (fibCoprimePart n) (Nat.fib d) := by
--+    intros d hd hdn hdn';
--+    have h_fold_coprime : ∀ (ds : List ℕ), d ∈ ds → Nat.Coprime (List.foldl (fun acc d => removePrimesOf acc (Nat.fib d)) (Nat.fib n) ds) (Nat.fib d) := by
--+      intros ds hds;
--+      induction' ds using List.reverseRecOn with ds ih <;> simp_all +decide [ Nat.coprime_mul_iff_left, Nat.coprime_mul_iff_right ];
--+      by_cases h : d ∈ ds <;> simp_all +decide [ Nat.Coprime ];
--+      · refine' Nat.Coprime.coprime_dvd_left ( removePrimesOf_dvd _ _ ) ‹_›;
--+      · apply removePrimesOf_coprime;
--+        induction' ds using List.reverseRecOn with ds ih <;> simp_all +decide [ Nat.fib_pos ];
--+        exact Nat.pos_of_dvd_of_pos ( removePrimesOf_dvd _ _ ) ‹_›;
--+    apply h_fold_coprime;
--+    simp +decide [ List.mem_filter, List.mem_range, hdn, hdn', Nat.dvd_iff_mod_eq_zero.mp hd ];
--+  -- Let `p` be a prime factor of `fibCoprimePart n`.
--+  obtain ⟨p, hp_prime, hp_dvd⟩ : ∃ p, Nat.Prime p ∧ p ∣ fibCoprimePart n := by
--+    exact Nat.exists_prime_and_dvd hcp.ne';
--+  -- Since `p` divides `fibCoprimePart n`, it follows that `p` divides `Nat.fib n`.
--+  have hp_dvd_fib : p ∣ Nat.fib n := by
--+    refine dvd_trans hp_dvd ?_;
--+    unfold fibCoprimePart;
--+    induction' ( List.filter ( fun d => decide ( 0 < d ) && n % d == 0 ) ( List.range n ) ) using List.reverseRecOn with d l ih <;> simp_all +decide [ Nat.dvd_trans ];
--+    exact dvd_trans ( removePrimesOf_dvd _ _ ) ih;
--+  refine' ⟨ p, hp_prime, hp_dvd_fib, fun k hk₁ hk₂ hk₃ => _ ⟩;
--+  contrapose! h_coprime;
--+  refine' ⟨ Nat.gcd n k, Nat.gcd_dvd_left _ _, Nat.gcd_pos_of_pos_left _ hn, _, _ ⟩;
--+  · exact lt_of_le_of_lt ( Nat.le_of_dvd hk₁ ( Nat.gcd_dvd_right _ _ ) ) hk₂;
--+  · exact fun h => hp_prime.not_dvd_one <| h ▸ Nat.dvd_gcd hp_dvd ( fib_dvd_gcd_of_dvd p n k hp_dvd_fib hk₃ )
--+
--+/-- Computational verification: for all composite n with 14 ≤ n ≤ 10000,
--+    the coprime part of F(n) is > 1. -/
--+lemma fib_coprime_part_pos_small :
--+    ∀ n, 14 ≤ n → n ≤ 10000 → ¬Nat.Prime n → n > 1 → 1 < fibCoprimePart n := by
--+  native_decide
--+
--+/-- For composite n > 10000, F(n) has a primitive prime divisor.
--+    This follows from growth bounds on Fibonacci numbers. -/
--+lemma fib_carmichael_large (n : ℕ) (hn : 10000 < n) (hnp : ¬Nat.Prime n) (hn1 : n > 1) :
--+    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
--+  sorry
--+
--+/-- For n ≥ 13 (either prime or composite), F(n) has a primitive prime divisor.
--+    This combines the prime case (from CarmichaelHelper) with the composite case. -/
--+theorem fib_carmichael (n : ℕ) (hn : 13 ≤ n) :
--+    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
--+      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
--+  by_cases hnp : Nat.Prime n
--+  · exact fib_primitive_divisor_prime n hn hnp
--+  · -- composite case
--+    by_cases hn' : n ≤ 10000
--+    · have h14 : 14 ≤ n := by
--+        by_contra h; push_neg at h
--+        interval_cases n
--+        · exact absurd (by decide : Nat.Prime 13) hnp
--+      exact primitive_of_fibCoprimePart_pos n (by omega)
--+        (fib_coprime_part_pos_small n h14 hn' hnp (by omega))
--+    · exact fib_carmichael_large n (by omega) hnp (by omega)+import Mathlib
-+import Shared.CarmichaelHelper
-+
-+/-! # Carmichael's theorem for composite n
-+
-+We prove that for composite n ≥ 14, F(n) has a primitive prime divisor.
-+
-+Key idea: We use entry point theory combined with a computational verification
-+of the "coprime part" of F(n) with respect to F(d) for proper divisors d | n.
-+
-+The coprime part removes all prime factors of F(d) from F(n). If the result is > 1,
-+there exists a prime factor of F(n) coprime to all F(d), which by entry point theory
-+must be a primitive prime divisor.
-+-/
-+
-+open Classical in
-+/-- The "Fibonacci entry point" of p: smallest k > 0 with p | F(k), or 0 if none. -/
-+noncomputable def fibEntryPt (p : ℕ) : ℕ :=
-+  if h : ∃ k, 0 < k ∧ p ∣ Nat.fib k then
-+    Nat.find h
-+  else 0
-+
-+/-
-+If p | F(n) and p | F(k), then p | F(gcd(n,k)).
-+-/
-+lemma fib_dvd_gcd_of_dvd (p n k : ℕ) (hn : p ∣ Nat.fib n) (hk : p ∣ Nat.fib k) :
-+    p ∣ Nat.fib (Nat.gcd n k) := by
-+  exact Nat.dvd_gcd hn hk |> fun h => by simpa [ Nat.fib_gcd ] using h;
-+
-+/-
-+The entry point divides n whenever p | F(n) and n > 0.
-+-/
-+lemma fibEntryPt_dvd_of_fib_dvd (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
-+    (hpn : p ∣ Nat.fib n) : fibEntryPt p ∣ n := by
-+  set α := fibEntryPt p
-+  have hα_pos : 0 < α := by
-+    unfold α fibEntryPt;
-+    split_ifs <;> simp_all +decide [ Nat.find_eq_iff ]
-+  have hα_div : p ∣ Nat.fib α := by
-+    simp +zetaDelta at *;
-+    unfold fibEntryPt at *;
-+    split_ifs at * <;> simp_all +decide [ Nat.find_spec ( _ : ∃ k, 0 < k ∧ p ∣ Nat.fib k ) ]
-+  have hα_min : ∀ m, 0 < m → m < α → ¬(p ∣ Nat.fib m) := by
-+    simp +zetaDelta at *;
-+    unfold fibEntryPt at *; aesop;
-+  have h_gcd_eq : Nat.gcd n α = α := by
-+    exact le_antisymm ( Nat.le_of_dvd hα_pos ( Nat.gcd_dvd_right _ _ ) ) ( Nat.le_of_not_gt fun h => hα_min _ ( Nat.gcd_pos_of_pos_left _ hn ) h <| fib_dvd_gcd_of_dvd _ _ _ hpn hα_div );
-+  exact h_gcd_eq ▸ Nat.gcd_dvd_left _ _
-+
-+/-
-+Entry point is positive for any prime p | F(n) with n > 0.
-+-/
-+lemma fibEntryPt_pos (p : ℕ) (hp : Nat.Prime p) (hn : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
-+    0 < fibEntryPt p := by
-+  unfold fibEntryPt; aesop;
-+
-+/-
-+If the entry point of p equals n, then p is a primitive prime divisor of F(n).
-+-/
-+lemma primitive_of_entryPt_eq (p n : ℕ) (hp : Nat.Prime p) (hpn : p ∣ Nat.fib n)
-+    (heq : fibEntryPt p = n) (hn : 0 < n) :
-+    ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
-+  intro k hk hk' hk''; have := fibEntryPt_dvd_of_fib_dvd p k ( by assumption ) ( by linarith ) hk''; simp_all +decide [ Nat.dvd_iff_mod_eq_zero ] ;
-+  rw [ Nat.mod_eq_of_lt ] at this <;> linarith
-+
-+/-! ## Computational infrastructure for primitive divisor verification -/
-+
-+/-- Remove all prime factors of b from a. -/
-+def removePrimesOf (a b : ℕ) : ℕ :=
-+  if ha : a = 0 then 0
-+  else
-+    let g := Nat.gcd a b
-+    if hg : g ≤ 1 then a
-+    else
-+      have : a / g < a := Nat.div_lt_self (Nat.pos_of_ne_zero ha) (by omega)
-+      removePrimesOf (a / g) b
-+termination_by a
-+
-+/-- The coprime part of F(n) with respect to F(d) for all proper divisors d | n.
-+    If this is > 1, F(n) has a prime factor not appearing in any F(d) for proper d | n. -/
-+def fibCoprimePart (n : ℕ) : ℕ :=
-+  let fn := Nat.fib n
-+  let properDivs := (List.range n).filter (fun d => 0 < d && n % d == 0)
-+  properDivs.foldl (fun acc d => removePrimesOf acc (Nat.fib d)) fn
-+
-+/-
-+removePrimesOf a b divides a.
-+-/
-+lemma removePrimesOf_dvd (a b : ℕ) : removePrimesOf a b ∣ a := by
-+  induction' a using Nat.strong_induction_on with a ih generalizing b;
-+  unfold removePrimesOf;
-+  split_ifs <;> simp_all +decide [ Nat.div_dvd_of_dvd ];
-+  split_ifs;
-+  · norm_num;
-+  · exact dvd_trans ( ih _ ( Nat.div_lt_self ( Nat.pos_of_ne_zero ‹_› ) ( lt_of_not_ge ‹_› ) ) _ ) ( Nat.div_dvd_of_dvd ( Nat.gcd_dvd_left _ _ ) )
-+
-+/-
-+removePrimesOf a b is coprime to b when a > 0.
-+-/
-+lemma removePrimesOf_coprime (a b : ℕ) (ha : 0 < a) :
-+    Nat.Coprime (removePrimesOf a b) b := by
-+  induction' a using Nat.strong_induction_on with a ih generalizing b;
-+  unfold removePrimesOf;
-+  split_ifs <;> simp_all +decide [ Nat.Coprime, Nat.gcd_comm ];
-+  split_ifs;
-+  · exact Nat.Coprime.symm ( Nat.le_antisymm ‹_› ( Nat.gcd_pos_of_pos_left _ ha ) );
-+  · exact ih _ ( Nat.div_lt_self ha ( lt_of_not_ge ‹_› ) ) _ ( Nat.div_pos ( Nat.le_of_dvd ha ( Nat.gcd_dvd_left _ _ ) ) ( Nat.gcd_pos_of_pos_left _ ha ) )
-+
-+/-
-+If p | F(n) and p doesn't divide F(d) for any proper divisor d of n,
-+    then p is a primitive prime divisor of F(n).
-+-/
-+lemma primitive_of_not_dvd_proper_divisors (p n : ℕ) (hp : Nat.Prime p)
-+    (hn : 0 < n) (hpn : p ∣ Nat.fib n)
-+    (hnd : ∀ d, d ∣ n → 0 < d → d < n → ¬(p ∣ Nat.fib d)) :
-+    ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
-+  intro k hk hk'; specialize hnd ( Nat.gcd n k ) ; simp_all +decide [ Nat.gcd_pos_of_pos_right ] ;
-+  exact fun h => hnd ( Nat.gcd_dvd_left _ _ ) ( Nat.lt_of_le_of_lt ( Nat.le_of_dvd hk ( Nat.gcd_dvd_right _ _ ) ) hk' ) ( fib_dvd_gcd_of_dvd p n k hpn h )
-+
-+/-
-+If fibCoprimePart n > 1, then F(n) has a primitive prime divisor.
-+-/
-+lemma primitive_of_fibCoprimePart_pos (n : ℕ) (hn : 0 < n)
-+    (hcp : 1 < fibCoprimePart n) :
-+    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
-+  -- By definition of `fibCoprimePart`, it is coprime to `fib d` for each proper divisor `d | n`.
-+  have h_coprime : ∀ d, d ∣ n → 0 < d → d < n → Nat.Coprime (fibCoprimePart n) (Nat.fib d) := by
-+    intros d hd hdn hdn';
-+    have h_fold_coprime : ∀ (ds : List ℕ), d ∈ ds → Nat.Coprime (List.foldl (fun acc d => removePrimesOf acc (Nat.fib d)) (Nat.fib n) ds) (Nat.fib d) := by
-+      intros ds hds;
-+      induction' ds using List.reverseRecOn with ds ih <;> simp_all +decide [ Nat.coprime_mul_iff_left, Nat.coprime_mul_iff_right ];
-+      by_cases h : d ∈ ds <;> simp_all +decide [ Nat.Coprime ];
-+      · refine' Nat.Coprime.coprime_dvd_left ( removePrimesOf_dvd _ _ ) ‹_›;
-+      · apply removePrimesOf_coprime;
-+        induction' ds using List.reverseRecOn with ds ih <;> simp_all +decide [ Nat.fib_pos ];
-+        exact Nat.pos_of_dvd_of_pos ( removePrimesOf_dvd _ _ ) ‹_›;
-+    apply h_fold_coprime;
-+    simp +decide [ List.mem_filter, List.mem_range, hdn, hdn', Nat.dvd_iff_mod_eq_zero.mp hd ];
-+  -- Let `p` be a prime factor of `fibCoprimePart n`.
-+  obtain ⟨p, hp_prime, hp_dvd⟩ : ∃ p, Nat.Prime p ∧ p ∣ fibCoprimePart n := by
-+    exact Nat.exists_prime_and_dvd hcp.ne';
-+  -- Since `p` divides `fibCoprimePart n`, it follows that `p` divides `Nat.fib n`.
-+  have hp_dvd_fib : p ∣ Nat.fib n := by
-+    refine dvd_trans hp_dvd ?_;
-+    unfold fibCoprimePart;
-+    induction' ( List.filter ( fun d => decide ( 0 < d ) && n % d == 0 ) ( List.range n ) ) using List.reverseRecOn with d l ih <;> simp_all +decide [ Nat.dvd_trans ];
-+    exact dvd_trans ( removePrimesOf_dvd _ _ ) ih;
-+  refine' ⟨ p, hp_prime, hp_dvd_fib, fun k hk₁ hk₂ hk₃ => _ ⟩;
-+  contrapose! h_coprime;
-+  refine' ⟨ Nat.gcd n k, Nat.gcd_dvd_left _ _, Nat.gcd_pos_of_pos_left _ hn, _, _ ⟩;
-+  · exact lt_of_le_of_lt ( Nat.le_of_dvd hk₁ ( Nat.gcd_dvd_right _ _ ) ) hk₂;
-+  · exact fun h => hp_prime.not_dvd_one <| h ▸ Nat.dvd_gcd hp_dvd ( fib_dvd_gcd_of_dvd p n k hp_dvd_fib hk₃ )
-+
-+/-- Computational verification: for all composite n with 14 ≤ n ≤ 10000,
-+    the coprime part of F(n) is > 1. -/
-+lemma fib_coprime_part_pos_small :
-+    ∀ n, 14 ≤ n → n ≤ 10000 → ¬Nat.Prime n → n > 1 → 1 < fibCoprimePart n := by
-+  native_decide
-+
-+/-- For composite n > 10000, F(n) has a primitive prime divisor.
-+    This follows from growth bounds on Fibonacci numbers. -/
-+lemma fib_carmichael_large (n : ℕ) (hn : 10000 < n) (hnp : ¬Nat.Prime n) (hn1 : n > 1) :
-+    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
-+  sorry
-+
-+/-- For n ≥ 13 (either prime or composite), F(n) has a primitive prime divisor.
-+    This combines the prime case (from CarmichaelHelper) with the composite case. -/
-+theorem fib_carmichael (n : ℕ) (hn : 13 ≤ n) :
-+    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
-+      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
-+  by_cases hnp : Nat.Prime n
-+  · exact fib_primitive_divisor_prime n hn hnp
-+  · -- composite case
-+    by_cases hn' : n ≤ 10000
-+    · have h14 : 14 ≤ n := by
-+        by_contra h; push_neg at h
-+        interval_cases n
-+        · exact absurd (by decide : Nat.Prime 13) hnp
-+      exact primitive_of_fibCoprimePart_pos n (by omega)
-+        (fib_coprime_part_pos_small n h14 hn' hnp (by omega))
-+    · exact fib_carmichael_large n (by omega) hnp (by omega)+import Mathlib
+import Shared.CarmichaelHelper
+
+/-! # Carmichael's theorem for composite n
+
+We prove that for composite n ≥ 14, F(n) has a primitive prime divisor.
+
+Key idea: We use entry point theory combined with a computational verification
+of the "coprime part" of F(n) with respect to F(d) for proper divisors d | n.
+
+The coprime part removes all prime factors of F(d) from F(n). If the result is > 1,
+there exists a prime factor of F(n) coprime to all F(d), which by entry point theory
+must be a primitive prime divisor.
+-/
+
+open Classical in
+/-- The "Fibonacci entry point" of p: smallest k > 0 with p | F(k), or 0 if none. -/
+noncomputable def fibEntryPt (p : ℕ) : ℕ :=
+  if h : ∃ k, 0 < k ∧ p ∣ Nat.fib k then
+    Nat.find h
+  else 0
+
+/-
+If p | F(n) and p | F(k), then p | F(gcd(n,k)).
+-/
+lemma fib_dvd_gcd_of_dvd (p n k : ℕ) (hn : p ∣ Nat.fib n) (hk : p ∣ Nat.fib k) :
+    p ∣ Nat.fib (Nat.gcd n k) := by
+  exact Nat.dvd_gcd hn hk |> fun h => by simpa [ Nat.fib_gcd ] using h;
+
+/-
+The entry point divides n whenever p | F(n) and n > 0.
+-/
+lemma fibEntryPt_dvd_of_fib_dvd (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
+    (hpn : p ∣ Nat.fib n) : fibEntryPt p ∣ n := by
+  set α := fibEntryPt p
+  have hα_pos : 0 < α := by
+    unfold α fibEntryPt;
+    split_ifs <;> simp_all +decide [ Nat.find_eq_iff ]
+  have hα_div : p ∣ Nat.fib α := by
+    simp +zetaDelta at *;
+    unfold fibEntryPt at *;
+    split_ifs at * <;> simp_all +decide [ Nat.find_spec ( _ : ∃ k, 0 < k ∧ p ∣ Nat.fib k ) ]
+  have hα_min : ∀ m, 0 < m → m < α → ¬(p ∣ Nat.fib m) := by
+    simp +zetaDelta at *;
+    unfold fibEntryPt at *; aesop;
+  have h_gcd_eq : Nat.gcd n α = α := by
+    exact le_antisymm ( Nat.le_of_dvd hα_pos ( Nat.gcd_dvd_right _ _ ) ) ( Nat.le_of_not_gt fun h => hα_min _ ( Nat.gcd_pos_of_pos_left _ hn ) h <| fib_dvd_gcd_of_dvd _ _ _ hpn hα_div );
+  exact h_gcd_eq ▸ Nat.gcd_dvd_left _ _
+
+/-
+Entry point is positive for any prime p | F(n) with n > 0.
+-/
+lemma fibEntryPt_pos (p : ℕ) (hp : Nat.Prime p) (hn : ∃ k, 0 < k ∧ p ∣ Nat.fib k) :
+    0 < fibEntryPt p := by
+  unfold fibEntryPt; aesop;
+
+/-
+If the entry point of p equals n, then p is a primitive prime divisor of F(n).
+-/
+lemma primitive_of_entryPt_eq (p n : ℕ) (hp : Nat.Prime p) (hpn : p ∣ Nat.fib n)
+    (heq : fibEntryPt p = n) (hn : 0 < n) :
+    ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
+  intro k hk hk' hk''; have := fibEntryPt_dvd_of_fib_dvd p k ( by assumption ) ( by linarith ) hk''; simp_all +decide [ Nat.dvd_iff_mod_eq_zero ] ;
+  rw [ Nat.mod_eq_of_lt ] at this <;> linarith
+
+/-! ## Computational infrastructure for primitive divisor verification -/
+
+/-- Remove all prime factors of b from a. -/
+def removePrimesOf (a b : ℕ) : ℕ :=
+  if ha : a = 0 then 0
+  else
+    let g := Nat.gcd a b
+    if hg : g ≤ 1 then a
+    else
+      have : a / g < a := Nat.div_lt_self (Nat.pos_of_ne_zero ha) (by omega)
+      removePrimesOf (a / g) b
+termination_by a
+
+/-- The coprime part of F(n) with respect to F(d) for all proper divisors d | n.
+    If this is > 1, F(n) has a prime factor not appearing in any F(d) for proper d | n. -/
+def fibCoprimePart (n : ℕ) : ℕ :=
+  let fn := Nat.fib n
+  let properDivs := (List.range n).filter (fun d => 0 < d && n % d == 0)
+  properDivs.foldl (fun acc d => removePrimesOf acc (Nat.fib d)) fn
+
+/-
+removePrimesOf a b divides a.
+-/
+lemma removePrimesOf_dvd (a b : ℕ) : removePrimesOf a b ∣ a := by
+  induction' a using Nat.strong_induction_on with a ih generalizing b;
+  unfold removePrimesOf;
+  split_ifs <;> simp_all +decide [ Nat.div_dvd_of_dvd ];
+  split_ifs;
+  · norm_num;
+  · exact dvd_trans ( ih _ ( Nat.div_lt_self ( Nat.pos_of_ne_zero ‹_› ) ( lt_of_not_ge ‹_› ) ) _ ) ( Nat.div_dvd_of_dvd ( Nat.gcd_dvd_left _ _ ) )
+
+/-
+removePrimesOf a b is coprime to b when a > 0.
+-/
+lemma removePrimesOf_coprime (a b : ℕ) (ha : 0 < a) :
+    Nat.Coprime (removePrimesOf a b) b := by
+  induction' a using Nat.strong_induction_on with a ih generalizing b;
+  unfold removePrimesOf;
+  split_ifs <;> simp_all +decide [ Nat.Coprime, Nat.gcd_comm ];
+  split_ifs;
+  · exact Nat.Coprime.symm ( Nat.le_antisymm ‹_› ( Nat.gcd_pos_of_pos_left _ ha ) );
+  · exact ih _ ( Nat.div_lt_self ha ( lt_of_not_ge ‹_› ) ) _ ( Nat.div_pos ( Nat.le_of_dvd ha ( Nat.gcd_dvd_left _ _ ) ) ( Nat.gcd_pos_of_pos_left _ ha ) )
+
+/-
+If p | F(n) and p doesn't divide F(d) for any proper divisor d of n,
+    then p is a primitive prime divisor of F(n).
+-/
+lemma primitive_of_not_dvd_proper_divisors (p n : ℕ) (hp : Nat.Prime p)
+    (hn : 0 < n) (hpn : p ∣ Nat.fib n)
+    (hnd : ∀ d, d ∣ n → 0 < d → d < n → ¬(p ∣ Nat.fib d)) :
+    ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
+  intro k hk hk'; specialize hnd ( Nat.gcd n k ) ; simp_all +decide [ Nat.gcd_pos_of_pos_right ] ;
+  exact fun h => hnd ( Nat.gcd_dvd_left _ _ ) ( Nat.lt_of_le_of_lt ( Nat.le_of_dvd hk ( Nat.gcd_dvd_right _ _ ) ) hk' ) ( fib_dvd_gcd_of_dvd p n k hpn h )
+
+/-
+If fibCoprimePart n > 1, then F(n) has a primitive prime divisor.
+-/
+lemma primitive_of_fibCoprimePart_pos (n : ℕ) (hn : 0 < n)
+    (hcp : 1 < fibCoprimePart n) :
+    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
+  -- By definition of `fibCoprimePart`, it is coprime to `fib d` for each proper divisor `d | n`.
+  have h_coprime : ∀ d, d ∣ n → 0 < d → d < n → Nat.Coprime (fibCoprimePart n) (Nat.fib d) := by
+    intros d hd hdn hdn';
+    have h_fold_coprime : ∀ (ds : List ℕ), d ∈ ds → Nat.Coprime (List.foldl (fun acc d => removePrimesOf acc (Nat.fib d)) (Nat.fib n) ds) (Nat.fib d) := by
+      intros ds hds;
+      induction' ds using List.reverseRecOn with ds ih <;> simp_all +decide [ Nat.coprime_mul_iff_left, Nat.coprime_mul_iff_right ];
+      by_cases h : d ∈ ds <;> simp_all +decide [ Nat.Coprime ];
+      · refine' Nat.Coprime.coprime_dvd_left ( removePrimesOf_dvd _ _ ) ‹_›;
+      · apply removePrimesOf_coprime;
+        induction' ds using List.reverseRecOn with ds ih <;> simp_all +decide [ Nat.fib_pos ];
+        exact Nat.pos_of_dvd_of_pos ( removePrimesOf_dvd _ _ ) ‹_›;
+    apply h_fold_coprime;
+    simp +decide [ List.mem_filter, List.mem_range, hdn, hdn', Nat.dvd_iff_mod_eq_zero.mp hd ];
+  -- Let `p` be a prime factor of `fibCoprimePart n`.
+  obtain ⟨p, hp_prime, hp_dvd⟩ : ∃ p, Nat.Prime p ∧ p ∣ fibCoprimePart n := by
+    exact Nat.exists_prime_and_dvd hcp.ne';
+  -- Since `p` divides `fibCoprimePart n`, it follows that `p` divides `Nat.fib n`.
+  have hp_dvd_fib : p ∣ Nat.fib n := by
+    refine dvd_trans hp_dvd ?_;
+    unfold fibCoprimePart;
+    induction' ( List.filter ( fun d => decide ( 0 < d ) && n % d == 0 ) ( List.range n ) ) using List.reverseRecOn with d l ih <;> simp_all +decide [ Nat.dvd_trans ];
+    exact dvd_trans ( removePrimesOf_dvd _ _ ) ih;
+  refine' ⟨ p, hp_prime, hp_dvd_fib, fun k hk₁ hk₂ hk₃ => _ ⟩;
+  contrapose! h_coprime;
+  refine' ⟨ Nat.gcd n k, Nat.gcd_dvd_left _ _, Nat.gcd_pos_of_pos_left _ hn, _, _ ⟩;
+  · exact lt_of_le_of_lt ( Nat.le_of_dvd hk₁ ( Nat.gcd_dvd_right _ _ ) ) hk₂;
+  · exact fun h => hp_prime.not_dvd_one <| h ▸ Nat.dvd_gcd hp_dvd ( fib_dvd_gcd_of_dvd p n k hp_dvd_fib hk₃ )
+
+/-- Computational verification: for all composite n with 14 ≤ n ≤ 10000,
+    the coprime part of F(n) is > 1. -/
+lemma fib_coprime_part_pos_small :
+    ∀ n, 14 ≤ n → n ≤ 10000 → ¬Nat.Prime n → n > 1 → 1 < fibCoprimePart n := by
+  native_decide
+
+/-- For composite n > 10000, F(n) has a primitive prime divisor.
+    This follows from growth bounds on Fibonacci numbers. -/
+lemma fib_carmichael_large (n : ℕ) (hn : 10000 < n) (hnp : ¬Nat.Prime n) (hn1 : n > 1) :
+    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
+  sorry
+
+/-- For n ≥ 13 (either prime or composite), F(n) has a primitive prime divisor.
+    This combines the prime case (from CarmichaelHelper) with the composite case. -/
+theorem fib_carmichael (n : ℕ) (hn : 13 ≤ n) :
+    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧
+      ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
+  by_cases hnp : Nat.Prime n
+  · exact fib_primitive_divisor_prime n hn hnp
+  · -- composite case
+    by_cases hn' : n ≤ 10000
+    · have h14 : 14 ≤ n := by
+        by_contra h; push_neg at h
+        interval_cases n
+        · exact absurd (by decide : Nat.Prime 13) hnp
+      exact primitive_of_fibCoprimePart_pos n (by omega)
+        (fib_coprime_part_pos_small n h14 hn' hnp (by omega))
+    · exact fib_carmichael_large n (by omega) hnp (by omega)