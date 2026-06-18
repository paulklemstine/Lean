## Research Task: Composite-index Fibonacci primitive divisors via entry-point divisibility equivalence and proper-divisor stripping

Research Mode: SORRY_FILL

The remaining `sorry`s in the Carmichael composite case should be attacked through the exact equivalence between “`p ∣ fib n`” and “entry point of `p` divides `n`”, together with the already scaffolded proper-divisor stripping machinery (`propDivs`, `stripAllAux`, `primPart`, residual positivity/factorization lemmas). The target is the composite-index half of Carmichael’s theorem:

```lean
theorem composite_index_fib_has_primitive_prime
    (n : ℕ) (hcomp : Nat.Composite n) (hn : 12 < n) :
    ∃ p : ℕ, Nat.Prime p ∧ p ∣ Nat.fib n ∧
      ∀ m : ℕ, 0 < m → m < n → ¬ p ∣ Nat.fib m
```

or the same theorem under the file’s existing hypotheses/packaging, e.g. with `¬ Nat.Prime n`, `2 ≤ n`, etc. Do not change the statement; fill the local `sorry`s in the form already present.

### Precise bridge lemmas that should be proved/found in context

The core local lemma needed for the final extraction step is almost certainly one of the following shapes:

```lean
theorem primitive_of_entryPt_eq
    {p n : ℕ} (hp : Nat.Prime p) (hn : 0 < n)
    (hdiv : p ∣ Nat.fib n) (hz : entryPoint p = n) :
    ∀ m : ℕ, 0 < m → m < n → ¬ p ∣ Nat.fib m
```

A slightly stronger and often easier-to-use equivalent form is:

```lean
theorem primitive_of_entryPt_eq'
    {p n m : ℕ} (hp : Nat.Prime p) (hn : 0 < n)
    (hz : entryPoint p = n) (hm0 : 0 < m) (hmn : m < n) :
    p ∣ Nat.fib n → ¬ p ∣ Nat.fib m
```

The proof should go by contradiction: if `p ∣ fib m`, then by the entry-point divisibility theorem one gets `entryPoint p ∣ m`; rewriting with `hz`, this gives `n ∣ m`, impossible because `0 < n` and `m < n`.

So the proof spine is:

1. Assume `p ∣ Nat.fib m`.
2. Apply the newly available theorem, likely one of
   ```lean
   fib_dvd_iff_entry_dvd
   entry_point_dvd_of_fib_dvd
   entry_point_divides
   ```
   to deduce `entryPoint p ∣ m`.
3. Rewrite using `hz : entryPoint p = n` to get `n ∣ m`.
4. From `hmn : m < n` and `hm0 : 0 < m`, derive contradiction, typically by
   `have hn0 : 0 < n := by omega`
   and then `exact Nat.not_dvd_of_pos_of_lt hm0 hmn ...` if available, or by
   `rcases hnmdiv with ⟨k, rfl⟩` and use arithmetic to show impossible unless `k = 0`, contradicting `hm0`.

A converse/selector lemma may also already be sorry’d:

```lean
theorem exists_prime_with_entryPoint_eq_n
    (n : ℕ) (hcomp : Nat.Composite n) (hn : 12 < n) :
    ∃ p : ℕ, Nat.Prime p ∧ p ∣ Nat.fib n ∧ entryPoint p = n
```

If this is the actual missing theorem, it is the real composite-case heart: once proved, the primitive-divisor theorem follows immediately from `primitive_of_entryPt_eq`.

### Main proof strategy for the composite case

If the file already has `primPart`/`stripAllAux` definitions and a theorem saying the stripped residual is positive or nontrivial, the intended argument is:

1. **Assume no primitive prime exists.**
   Formal negation should yield:
   ```lean
   ∀ p, Nat.Prime p → p ∣ Nat.fib n →
     ∃ m, 0 < m ∧ m < n ∧ p ∣ Nat.fib m
   ```
   Using the entry-point theorem, sharpen this to:
   ```lean
   ∀ p, Nat.Prime p → p ∣ Nat.fib n → entryPoint p < n
   ```
   and in fact `entryPoint p ∣ n`, so `entryPoint p` is a proper divisor of `n`.

2. **Every prime divisor of `fib n` comes from a proper divisor of `n`.**
   For each prime `p ∣ fib n`, use `entry_point_dvd_of_fib_dvd` to obtain `entryPoint p ∣ n`.
   If `entryPoint p = n`, then `p` is primitive by the bridge lemma above, contradiction.
   Therefore `entryPoint p` is a proper divisor of `n`, and by the defining property of entry points you also have
   ```lean
   p ∣ Nat.fib (entryPoint p)
   ```
   so `p` is already captured by one of the proper-divisor Fibonacci values.

3. **Transfer this prime-support containment into a divisibility/product statement.**
   This is exactly where the file’s `propDivs` / `stripAllAux` / `primPart_dvd` / residual factorization lemmas should be used. The intended conclusion is something like:
   ```lean
   primPart n ∣ ∏ d in propDivs n, Nat.fib d
   ```
   or that after stripping all prime powers contributed by proper divisors, the residual part of `fib n` is `1`. If there is a theorem already reducing primewise support containment to divisibility of `stripAllAux`, use it rather than reproving a valuation theorem from scratch.

4. **Contradict the residual positivity/nontriviality theorem already present.**
   The existing framework apparently proves that for composite `n > 12`, after removing contributions coming from proper divisors, a positive residual factor remains. The contradiction should be between:
   - “all prime divisors are accounted for by proper divisors” from Step 3, and
   - “the stripped residual is > 1” or at least has a prime divisor, from the file’s positivity theorem.

5. **Extract the desired prime.**
   Once the residual part is shown nontrivial, use `Nat.exists_prime_and_dvd` (or the local analogue) to obtain a prime `p` dividing it; then convert `p ∣ primPart n` into `p ∣ fib n` and `p ∤ fib m` for each proper `m < n`, in particular for all `0 < m < n`.

### Important arithmetic sublemmas likely needed in the local sorries

The composite-case proof often needs the standard proper-divisor bound for composite indices:

```lean
lemma proper_divisor_le_half
    {m n : ℕ} (hmn : m ∣ n) (hm0 : 0 < m) (hlt : m < n) :
    m ≤ n / 2
```

This is useful if the file’s positivity estimate compares `fib n` against products over proper divisors by reducing all proper divisors to indices `≤ n/2`.

A common proof is:
- write `n = m * k` with `k ≥ 2` because `m < n` and `m > 0`,
- then `n ≥ 2*m`,
- hence `m ≤ n/2`.

If the file already has this lemma sorry’d, prove it directly with `rcases hmn with ⟨k, rfl⟩` and arithmetic (`omega`/`linarith` if imported, otherwise `Nat.mul_le_mul_left`, `Nat.succ_le_of_lt`, etc.).

Another recurring lemma is the entry-point minimality implication:

```lean
lemma entryPoint_ne_of_lt
    {p n m : ℕ} (hz : entryPoint p = n) (hm0 : 0 < m) (hmn : m < n) :
    entryPoint p ∣ m → False
```

This is just a convenient wrapper around `n ∣ m` being impossible for `0 < m < n`.

### Concrete Lean proof hints for the bridge lemma

For `primitive_of_entryPt_eq`, the proof should look close to:

```lean
  intro m hm0 hmn hpm
  have hEPdvd : entryPoint p ∣ m := by
    exact entry_point_dvd_of_fib_dvd p m hp hm0 hpm
  have hndvd : n ∣ m := by
    simpa [hz] using hEPdvd
  exact Nat.not_dvd_of_pos_of_lt hm0 hmn hndvd
```

If `Nat.not_dvd_of_pos_of_lt` is unavailable or mismatched, use:

```lean
  rcases hndvd with ⟨k, hk⟩
  have hkpos : 1 ≤ k := by
    by_contra hk0
    have : k = 0 := Nat.eq_zero_of_not_pos (by simpa using hk0)
    subst this
    simp at hk
    omega
  have : n ≤ m := by
    subst hk
    calc
      n = n * 1 := by simp
      _ ≤ n * k := Nat.mul_le_mul_left _ hkpos
  exact Nat.not_le_of_lt hmn this
```

If the theorem available is the biconditional
```lean
fib_dvd_iff_entry_dvd
```
then use its `mp` direction:
```lean
have hEPdvd : entryPoint p ∣ m := (fib_dvd_iff_entry_dvd hp hm0).mp hpm
```
adjusting arguments to the actual local signature.

### What to inspect in the file before proving anything

The exact names matter. Search in the surrounding context for:
- `entryPoint`, `entry_point`, `orderApp`, `rank`, `zsigmondy`
- `fib_dvd_iff_entry_dvd`, `entry_point_dvd_of_fib_dvd`, `entry_point_divides`
- `propDivs`, `properDivisors`, `stripAllAux`, `stripAll`, `primPart`
- residual lemmas of the form `... > 1`, `... ≠ 1`, `Nat.exists_prime_and_dvd`
- a theorem already reducing prime-divisor support containment to divisibility of the stripped product.

Very likely the final theorem is already structured as:
- prime case handled by `fib_primitive_divisor_prime`,
- composite case reduced to one or two local sorry’d lemmas,
- a top-level Carmichael theorem dispatching on `Nat.Prime n`.

So the highest-value fills are the bridge theorem `primitive_of_entryPt_eq` and the contradiction theorem showing `∃ p, entryPoint p = n`.

### Significance for the research program

This closes the composite branch of Carmichael’s theorem in the Fibonacci setting, which is the main remaining obstruction after the prime-index case and the entry-point divisibility equivalence were established. Formally, it upgrades the entry-point theory from a divisibility classification to an actual primitive-divisor extraction mechanism. That is the key step needed to complete the “every `n > 12` has a Fibonacci primitive prime divisor” theorem in a way compatible with the existing residual-factorization architecture, and it turns the recently proved `fib_dvd ↔ entryPoint ∣ index` bridge into a decisive structural tool rather than an isolated lemma.

### Catalog Reference Files
            @Shared/CarmichaelProof.lean
```lean
--- a/Shared/CarmichaelProof.lean
+++ b/Shared/CarmichaelProof.lean
@@ -1,5 +1,6 @@
 import Mathlib
 import Shared.CarmichaelHelper
+import Shared.FibonacciLTE

 /-! # Complete proof of Carmichael's theorem (composite case)
```

@Speculative/AutoResearch/CarmichaelComposite.lean
```lean
--- a/Speculative/AutoResearch/CarmichaelComposite.lean
+++ b/Speculative/AutoResearch/CarmichaelComposite.lean
@@ -1,18 +1,181 @@
---- a/Speculative/AutoResearch/CarmichaelComposite.lean
-+++ b/Speculative/AutoResearch/CarmichaelComposite.lean
-@@ -1,5 +1,6 @@
- import Mathlib
- import Shared.CarmichaelHelper
-+import Shared.CarmichaelProof
- 
- /-! # Carmichael's theorem for composite n
- 
-@@ -161,7 +162,7 @@
-     This follows from growth bounds on Fibonacci numbers. -/
- lemma fib_carmichael_large (n : ℕ) (hn : 10000 < n) (hnp : ¬Nat.Prime n) (hn1 : n > 1) :
-     ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
--  sorry
-+  exact fib_carmichael_composite n (by omega) hnp
- 
- /-- For n ≥ 13 (either prime or composite), F(n) has a primitive prime divisor.
-     This combines the prime case (from CarmichaelHelper) with the composite case. -/+import Mathlib
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
-- ... (truncated, full file has 201 lines)
```

@Speculative/AutoResearch/Primitive_Prime_Divisors_of_Composite_Index_Fibonacci_Numbers_via_LTE_and_Entry_Point_Theory.lean
```lean
import Mathlib

/-!
# Carmichael's Primitive Divisor Theorem for Fibonacci Numbers (Composite Index Case)

This file proves structural results toward Carmichael's theorem that for every
composite natural number `n > 10000`, the Fibonacci number `F_n` has a
**primitive prime divisor**: a prime `p` that divides `F_n` but does not
divide `F_k` for any `0 < k < n`.

## Main results

* `entry_point_dvd_of_fib_dvd`: The entry point (rank of apparition) of a prime
  in the Fibonacci sequence divides `n` whenever `p ∣ F_n`.
* `fib_dvd_iff_entry_dvd`: A prime `p` divides `F_k` if and only if its entry
  point divides `k`.
* `fib_composite_has_primitive`: The main theorem (composite case of Carmichael's
  theorem). Uses a sorry for the core number-theoretic step.

## Implementation notes

The full proof of Carmichael's theorem requires the theory of cyclotomic Fibonacci
numbers Φ_n (primitive parts), specifically:
1. The multiplicative identity `F_n = ∏_{d|n} Φ_d`
2. The lower bound `Φ_n ≈ φ^{φ(n)}` (Euler's totient function)
3. The intrinsic factor theorem: primes dividing Φ_n and Φ_d (for d | n, d < n)
   must divide n

This infrastructure is not currently available in Mathlib. The entry point theory
and supporting lemmas are fully proved; only the core growth/cyclotomic step
remains as a sorry.
-/

open scoped BigOperators
open Finset Nat

set_option maxHeartbeats 1600000

/-! ## Entry point theory for Fibonacci primes -/

/-- If `p ∣ F_m` and `p ∣ F_n`, then `p ∣ F_{gcd m n}`.
This follows from the strong divisibility property `gcd(F_m, F_n) = F_{gcd(m,n)}`. -/
lemma prime_dvd_fib_gcd (p m n : ℕ) (hp : Nat.Prime p)
    (hm : p ∣ Nat.fib m) (hn : p ∣ Nat.fib n) :
    p ∣ Nat.fib (Nat.gcd m n) := by
  exact Nat.dvd_gcd hm hn |> fun h => by simpa [fib_gcd] using h

/-- Every prime divides some positive Fibonacci number.
This follows from the Pisano period: the Fibonacci sequence mod `p` is periodic,
so the pair `(0, 1)` must recur, giving `F_k ≡ 0 (mod p)` for some `k > 0`. -/
lemma prime_dvd_some_fib (p : ℕ) (hp : Nat.Prime p) :
    ∃ k, 0 < k ∧ p ∣ Nat.fib k := by
  have h_pigeonhole : ∃ i j : ℕ, i < j ∧ (fib i % p = fib j % p) ∧
      (fib (i + 1) % p = fib (j + 1) % p) := by
    have h_finite : Set.Finite ((fun k => (fib k % p, fib (k + 1) % p)) '' Set.Ici 0) := by
      exact Set.finite_iff_bddAbove.mpr ⟨⟨p - 1, p - 1⟩, by
        rintro a ⟨k, -, rfl⟩
        exact ⟨Nat.le_sub_one_of_lt (Nat.mod_lt _ hp.pos),
               Nat.le_sub_one_of_lt (Nat.mod_lt _ hp.pos)⟩⟩
    contrapose! h_finite
    exact Set.infinite_of_injective_forall_mem
      (fun i j hij => le_antisymm
        (not_lt.1 fun hi => h_finite _ _ hi (by aesop) (by aesop))
        (not_lt.1 fun hj => h_finite _ _ hj (by aesop) (by aesop)))
      fun i => ⟨i, by norm_num, rfl⟩
  obtain ⟨i, j, hij, hi, hj⟩ := h_pigeonhole
  induction' i with i ih generalizing j
  · induction' j with j ih' <;> simp_all +decide [Nat.fib_add_two, Nat.dvd_iff_mod_eq_zero]
    exact ⟨j + 1, by linarith, by simp +decide [← hi]⟩
  · specialize ih (j - 1) (Nat.lt_pred_iff.mpr hij)
    rcases j <;> simp_all +decide [Nat.fib_add_two, Nat.add_mod]
    simp_all +decide [← ZMod.natCast_eq_natCast_iff']

/-- The entry point (rank of apparition) of a prime divides `n` whenever `p ∣ F_n`.
Returns the minimal positive `d` such that `d ∣ n`, `p ∣ F_d`, and `p ∤ F_k`
for all `0 < k < d`. -/
lemma entry_point_dvd_of_fib_dvd (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
    (hpn : p ∣ Nat.fib n) :
    ∃ d, 0 < d ∧ d ∣ n ∧ p ∣ Nat.fib d ∧ ∀ k, 0 < k → k < d → ¬(p ∣ Nat.fib k) := by
  obtain ⟨d, hd1, hd2, hd3⟩ : ∃ d, 0 < d ∧ p ∣ fib d ∧ ∀ k, 0 < k → k < d → ¬p ∣ fib k := by
    have := prime_dvd_some_fib p hp
    exact ⟨Nat.find this, Nat.find_spec this |>.1, Nat.find_spec this |>.2, by aesop⟩
  refine ⟨d, hd1, ?_, hd2, hd3⟩
  contrapose! hd3
  exact ⟨Nat.gcd d n, Nat.gcd_pos_of_pos_left _ hd1,
    lt_of_le_of_ne (Nat.le_of_dvd hd1 (Nat.gcd_dvd_left _ _))
      fun con => hd3 <| con ▸ Nat.gcd_dvd_right _ _,
    prime_dvd_fib_gcd p d n hp hd2 hpn⟩

/-- A prime `p` divides `F_k` if and only if its entry point `d` divides `k`.
This is the fundamental characterization of divisibility in the Fibonacci sequence. -/
lemma fib_dvd_iff_entry_dvd (p d k : ℕ) (hp : Nat.Prime p) (hd : 0 < d)
    (hpd : p ∣ Nat.fib d) (hmin : ∀ j, 0 < j → j < d → ¬(p ∣ Nat.fib j))
    (hk : 0 < k) : p ∣ Nat.fib k ↔ d ∣ k := by
  constructor
  · contrapose! hmin
    use Nat.gcd d k
    exact ⟨Nat.gcd_pos_of_pos_left _ hd,
      lt_of_le_of_ne (Nat.le_of_dvd hd (Nat.gcd_dvd_left _ _))
        fun con => hmin.2 <| con ▸ Nat.gcd_dvd_right _ _,
      prime_dvd_fib_gcd _ _ _ hp hpd hmin.1⟩
  · exact fun h => dvd_trans hpd (Nat.fib_dvd _ _ h)

/-! ## Fibonacci growth bounds -/

/-- For composite `n > 1`, every proper divisor is at most `n / 2`. -/
lemma composite_proper_div_le_half (n : ℕ) (hn : n > 1) (hcomp : ¬Nat.Prime n)
    (d : ℕ) (hd : d ∣ n) (hdn : d < n) : d ≤ n / 2 := by
  rw [Nat.le_div_iff_mul_le (by norm_num : (0:ℕ) < 2)]
  obtain ⟨k, rfl⟩ := hd
  have hk : k > 1 := by
    rcases k with _ | _ | k
    · omega
    · simp at hcomp; exact absurd (by omega : d * 1 < d * 1 + d) (by omega)
    · omega
  nlinarith

/-- `F_n ≥ 2` for `n ≥ 3`. -/
lemma fib_ge_two (n : ℕ) (hn : n ≥ 3) : Nat.fib n ≥ 2 :=
  Nat.le_trans (by decide) (Nat.fib_mono hn)

/-- `F_n ≠ 1` for `n ≥ 3`. -/
lemma fib_ne_one (n : ℕ) (hn : n ≥ 3) : Nat.fib n ≠ 1 :=
  Nat.ne_of_gt (fib_ge_two n hn)

/-- Fibonacci is strictly monotone for indices ≥ 2. -/
lemma fib_strict_mono {a b : ℕ} (ha : 2 ≤ a) (hab : a < b) : Nat.fib a < Nat.fib b := by
  induction hab <;> simp_all +arith +decide [Nat.fib_add_two]
  · rcases a with _ | _ | a <;> simp_all +arith +decide [Nat.fib_add_two]
  · exact lt_of_lt_of_le ‹_› (Nat.fib_mono (Nat.le_succ _))

/-- `F_n ≤ 2^n` for all `n`. -/
lemma fib_le_two_pow (n : ℕ) : Nat.fib n ≤ 2 ^ n := by
  induction' n using Nat.strong_induction_on with n ih
  rcases n with _ | _ | _ | n <;> simp +arith +decide [Nat.fib_add_two, *]
  grind

/-- `F_n ≥ n` for `n ≥ 5`. -/
lemma fib_ge_id (n : ℕ) (hn : n ≥ 5) : Nat.fib n ≥ n := by
  induction hn <;> simp +arith +decide [Nat.fib_add_two, *]
  rename_i m hm ih
  rcases m with _ | _ | _ | _ | _ | m <;> simp_all +arith +decide [Nat.fib_add_two]
  grind +splitIndPred

/-! ## Main theorem -/

/-- **Carmichael's Primitive Divisor Theorem (composite index case)**.

For composite `n > 10000`, the Fibonacci number `F_n` has a primitive prime divisor:
a prime `p` such that `p ∣ F_n` but `p ∤ F_k` for every `0 < k < n`.
-- ... (truncated, full file has 169 lines)
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
