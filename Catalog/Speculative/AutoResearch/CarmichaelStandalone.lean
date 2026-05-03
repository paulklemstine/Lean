--- a/Speculative/AutoResearch/CarmichaelStandalone.lean
+++ b/Speculative/AutoResearch/CarmichaelStandalone.lean
@@ -47,9 +47,56 @@
     simp [List.foldl]
     exact dvd_trans (stripAllAux_dvd _ _ _) ih
 
+lemma stripAllAux_coprime (r m fuel : ℕ) (hm : 1 < m) (hr : 0 < r) (hfuel : r ≤ fuel) :
+    Nat.gcd (stripAllAux r m fuel) m = 1 := by
+  induction' fuel with fuel ih generalizing r m;
+  · grind +qlia;
+  · by_cases hgr : Nat.gcd r m > 1;
+    · convert ih ( r / Nat.gcd r m ) m hm ( Nat.div_pos ( Nat.le_of_dvd hr ( Nat.gcd_dvd_left _ _ ) ) hgr.le ) _ using 1;
+      · grind +locals;
+      · exact Nat.le_of_lt_succ ( Nat.div_lt_of_lt_mul <| by nlinarith [ Nat.div_mul_cancel ( Nat.gcd_dvd_left r m ) ] );
+    · interval_cases _ : Nat.gcd r m <;> simp_all +decide [ stripAllAux ]
+
+lemma primPart_coprime_proper_divs (n : ℕ) (hpp : 1 < primPart n) (d : ℕ)
+    (hd : d ∈ propDivs n) : ¬((primPart n).minFac ∣ Nat.fib d) := by
+  have h_coprime : Nat.gcd (primPart n) (Nat.fib d) = 1 := by
+    have h_coprime : ∀ l : List ℕ, d ∈ l → Nat.gcd (List.foldl (fun r d => stripAllAux r (Nat.fib d) r) (Nat.fib n) l) (Nat.fib d) = 1 := by
+      intros l hl; induction' l using List.reverseRecOn with l ih <;> simp_all +decide [ Nat.gcd_comm ] ;
+      by_cases h : Nat.fib ih > 1 <;> by_cases h' : 0 < List.foldl ( fun r d => stripAllAux r ( Nat.fib d ) r ) ( Nat.fib n ) l <;> simp_all +decide [ Nat.gcd_comm ];
+      · have := stripAllAux_coprime ( List.foldl ( fun r d => stripAllAux r ( Nat.fib d ) r ) ( Nat.fib n ) l ) ( Nat.fib ih ) ( List.foldl ( fun r d => stripAllAux r ( Nat.fib d ) r ) ( Nat.fib n ) l ) h h' ( by linarith ) ; simp_all +decide [ Nat.gcd_comm ] ;
+        cases hl <;> simp_all +decide [ Nat.gcd_comm ];
+        exact Nat.Coprime.coprime_dvd_right ( stripAllAux_dvd _ _ _ ) ‹_›;
+      · have h_contra : ∀ l : List ℕ, List.foldl (fun r d => stripAllAux r (Nat.fib d) r) (Nat.fib n) l = 0 → False := by
+          intros l hl; induction' l using List.reverseRecOn with l ih <;> simp_all +decide [ Nat.gcd_comm ] ;
+          have := stripAllAux_dvd ( List.foldl ( fun r d => stripAllAux r ( Nat.fib d ) r ) ( Nat.fib n ) l ) ( Nat.fib ih ) ( List.foldl ( fun r d => stripAllAux r ( Nat.fib d ) r ) ( Nat.fib n ) l ) ; simp_all +decide [ Nat.gcd_comm ] ;
+        exact False.elim <| h_contra l h';
+      · rcases ih with ( _ | _ | ih ) <;> simp_all +arith +decide [ Nat.fib_add_two ];
+        · cases hl <;> simp_all +decide [ propDivs ];
+          unfold stripAllAux; aesop;
+        · unfold stripAllAux; aesop;
+        · rcases ih with ( _ | _ | ih ) <;> simp_all +arith +decide [ Nat.fib_add_two ];
+          · unfold stripAllAux; aesop;
+          · linarith [ Nat.fib_pos.2 ( Nat.succ_pos ih ) ];
+      · have h_contra : List.foldl (fun r d => stripAllAux r (Nat.fib d) r) (Nat.fib n) l ∣ Nat.fib n := by
+          have h_contra : ∀ l : List ℕ, List.foldl (fun r d => stripAllAux r (Nat.fib d) r) (Nat.fib n) l ∣ Nat.fib n := by
+            intro l; induction' l using List.reverseRecOn with l ih <;> simp_all +decide [ Nat.gcd_comm ] ;
+            exact dvd_trans ( stripAllAux_dvd _ _ _ ) ‹_›;
+          exact h_contra l;
+        rcases n with ( _ | _ | n ) <;> simp_all +decide [ Nat.fib_add_two ];
+    exact h_coprime _ hd;
+  exact fun h => Nat.Prime.not_dvd_one ( Nat.minFac_prime hpp.ne' ) ( h_coprime ▸ Nat.dvd_gcd ( Nat.minFac_dvd _ ) h )
+
 lemma primPart_implies_primitive (n : ℕ) (hn : 3 ≤ n) (hpp : 1 < primPart n) :
     ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
-  sorry -- already proven in main file, just need skeleton here
+  have h_div : primPart n ∣ Nat.fib n := primPart_dvd n
+  refine' ⟨ Nat.minFac ( primPart n ), Nat.minFac_prime hpp.ne', dvd_trans ( Nat.minFac_dvd _ ) h_div, _ ⟩;
+  intro k hk hk';
+  by_cases h_div_k : Nat.minFac (primPart n) ∣ Nat.fib (Nat.gcd k n);
+  · have h_div_k : Nat.gcd k n ∈ propDivs n := by
+      simp +decide [ propDivs ];
+      exact ⟨ lt_of_le_of_lt ( Nat.le_of_dvd hk ( Nat.gcd_dvd_left _ _ ) ) hk', ⟨ Or.inl hk, lt_of_le_of_lt ( Nat.le_of_dvd hk ( Nat.gcd_dvd_left _ _ ) ) hk' ⟩, Nat.mod_eq_zero_of_dvd ( Nat.gcd_dvd_right _ _ ) ⟩;
+    exact absurd ( primPart_coprime_proper_divs n hpp _ h_div_k ) ( by aesop );
+  · exact fun h => h_div_k <| Nat.dvd_gcd h ( Nat.dvd_trans ( Nat.minFac_dvd _ ) h_div ) |> fun x => by simpa [ Nat.fib_gcd ] using x;
 
 /-- Verified: for all n ∈ [13, 10000], either n is prime or primPart n > 1 -/
 theorem primPart_check : ∀ n ∈ Finset.Icc 13 10000, Nat.Prime n ∨ 1 < primPart n := by