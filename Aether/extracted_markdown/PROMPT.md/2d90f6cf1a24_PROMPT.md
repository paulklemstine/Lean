## Research Task: Composite-index Fibonacci primitive divisors via entry-point divisibility equivalence

Research Mode: SORRY_FILL

Fill the `sorry` placeholders in the Carmichael/Fibonacci files around the entry-point machinery and the composite-index primitive-divisor theorem. Do not change statements. If a proof is difficult in-line, add local helper lemmas in the same file immediately before the target theorem.

### Files / likely targets
Work primarily in:
- `Shared/CarmichaelCompositeEntryPoint.lean`
- `Shared/CarmichaelProof.lean`

The missing bridge is the divisibility-to-entry-point mechanism needed by the already-present composite primitive-divisor infrastructure. The crucial theorem already appears to exist in some form:

```lean
lemma entry_point_divides
    (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n) (hpn : p ∣ Nat.fib n) :
    entryPoint p ∣ n
```

If this exact theorem is sorry’d, prove it directly. If nearby lemmas are sorry’d instead, use the same strategy below to discharge them and then derive this theorem.

### Precise target statements to keep in view
The key mathematical bridge should amount to one or more of the following exact Lean shapes already suggested by the surrounding context:

```lean
lemma entry_point_pos (p : ℕ) (hp : Nat.Prime p) : 0 < entryPoint p
```

```lean
lemma entry_point_spec (p : ℕ) (hp : Nat.Prime p) :
    p ∣ Nat.fib (entryPoint p)
```

```lean
lemma entry_point_minimal
    (p k : ℕ) (hp : Nat.Prime p) (hk : 0 < k) (hkfib : p ∣ Nat.fib k) :
    entryPoint p ≤ k
```

```lean
lemma entry_point_divides
    (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n) (hpn : p ∣ Nat.fib n) :
    entryPoint p ∣ n
```

Very likely there is also a gcd-based lemma of one of these forms:

```lean
lemma prime_dvd_fib_gcd
    (p m n : ℕ) (hp : Nat.Prime p)
    (hm : p ∣ Nat.fib m) (hn : p ∣ Nat.fib n) :
    p ∣ Nat.fib (Nat.gcd m n)
```

or

```lean
lemma fib_dvd_of_dvd (h : m ∣ n) : Nat.fib m ∣ Nat.fib n
```

or the stronger criterion

```lean
lemma fib_dvd_iff_dvd : Nat.fib m ∣ Nat.fib n ↔ m ∣ n
```

If the stronger equivalence is not already in the file, do not force it globally unless needed; the essential local bridge is that a prime dividing two Fibonacci numbers also divides the Fibonacci number at the gcd index, which then lets minimality force divisibility of indices.

### Concrete proof strategy
1. **Exploit the gcd identity for Fibonacci numbers.**  
   Search the local file / imports for a theorem equivalent to
   `Nat.gcd (Nat.fib m) (Nat.fib n) = Nat.fib (Nat.gcd m n)`.
   Mathlib often has Fibonacci gcd lemmas already; if not, the file may already contain a specialized version. From
   `hm : p ∣ fib m` and `hn : p ∣ fib n`, deduce
   `p ∣ gcd (fib m) (fib n)`, hence `p ∣ fib (gcd m n)` after rewriting by the gcd-Fibonacci theorem.

2. **Use the defining minimality of `entryPoint p`.**  
   The structure of `entryPoint` is almost certainly “the least positive index whose Fibonacci number is divisible by `p`”. Unfold only as much as necessary. Usually the surrounding lemmas already package:
   - positivity: `0 < entryPoint p`
   - divisibility at the entry point: `p ∣ fib (entryPoint p)`
   - minimality among positive witnesses  
   If minimality is encoded through `Nat.find`, the standard pattern is:
   ```lean
   rcases Nat.find_spec ... with ⟨hpos, hdiv⟩
   exact hpos
   ```
   and for minimality:
   ```lean
   exact Nat.find_min' ... ⟨hk, hkfib⟩
   ```
   Adjust to the actual sigma/subtype used in the file.

3. **Derive `entryPoint p ∣ n` from gcd minimality.**  
   Let `z := entryPoint p`. Since `p ∣ fib z` and `p ∣ fib n`, the gcd lemma gives
   `p ∣ fib (gcd z n)`. Also `gcd_pos_of_pos_left _ (entry_point_pos p hp)` gives positivity of `gcd z n`. By minimality of `z`, obtain
   `z ≤ gcd z n`. But always `Nat.gcd_le_left z n : Nat.gcd z n ≤ z`. Hence
   `Nat.gcd z n = z`, and now conclude `z ∣ n` via:
   ```lean
   exact Nat.dvd_of_gcd_eq_left hGcd
   ```
   or by rewriting `hGcd : Nat.gcd z n = z` / `z = Nat.gcd z n` and using `Nat.gcd_dvd_right`.

4. **For composite primitive-divisor filtering, convert “divides a proper-divisor Fibonacci” into “entry point divides that proper divisor”.**  
   In the proof of `fib_composite_has_primitive`, when a prime `p ∣ Nat.fib n` is assumed also to divide `Nat.fib d` for some proper divisor `d ∣ n`, apply `entry_point_divides` twice:
   - `entryPoint p ∣ n`
   - `entryPoint p ∣ d`
   If the construction of the residual prime ensures its entry point is exactly `n`, derive a contradiction from `d < n`. This is the conceptual reason the bridge theorem is the missing piece.

5. **Be careful about the small-index exceptional cases.**  
   The composite theorem is only for `n > 12`, so once you are inside that theorem, positivity facts like `0 < n`, `2 ≤ n`, and nontriviality of proper divisors should be easy. Use `linarith` / `omega` if imported; otherwise `Nat.succ_le_of_lt`, `lt_of_lt_of_le`, and `norm_num` are enough. Do not overcomplicate the large-index part with unnecessary case splits.

### Lean-specific hints
- If `entryPoint` is defined by `Nat.find` over an existence theorem saying there exists a positive index with `p ∣ fib k`, the standard helper lemmas are likely easiest to prove by:
  ```lean
  unfold entryPoint
  exact (Nat.find_spec _).1
  ```
  or a variant depending on the witness shape.
- For prime divisibility into a gcd:
  ```lean
  have hpg : p ∣ Nat.gcd (Nat.fib a) (Nat.fib b) := ⟨..., by exact Nat.dvd_gcd ha hb⟩
  ```
  usually just:
  ```lean
  have hpg : p ∣ Nat.gcd (Nat.fib a) (Nat.fib b) := Nat.dvd_gcd ha hb
  ```
- To turn gcd equality into divisibility:
  ```lean
  have hg : Nat.gcd z n = z := ...
  have : z ∣ n := by
    rw [← hg]
    exact Nat.gcd_dvd_right z n
  ```
  If the equality is in the opposite direction, `simpa [hg] using Nat.gcd_dvd_right z n`.
- Positivity of gcd:
  ```lean
  have hzpos : 0 < z := entry_point_pos p hp
  have hgpos : 0 < Nat.gcd z n := Nat.gcd_pos_of_pos_left n hzpos
  ```
  Check argument order; there are both left/right variants.

### Why this matters
This bridge theorem is the formal heart of the composite-index half of Carmichael’s primitive-divisor theorem for Fibonacci numbers. The prime-index case is already established; the remaining obstruction is exactly the inability to pass from “`p` divides a Fibonacci value” to “the index of first occurrence divides the current index.” Once this is in place, the existing `stripAllAux` / `primPart` machinery can certify that after removing prime factors arising from proper divisors, a genuinely new prime remains at composite index `n > 12`. Closing these sorries therefore does not just tidy local lemmas: it completes the number-theoretic mechanism needed to finish `fib_composite_has_primitive` and substantially advances the full Carmichael formalization.

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

@Speculative/AutoResearch/FibPrimitive.lean
```lean
/-
# Carmichael's Theorem: Primitive Prime Divisors of Fibonacci Numbers

For every composite n ≥ 13, the Fibonacci number F(n) has at least one
primitive prime divisor — a prime p dividing F(n) that does not divide
F(k) for any 0 < k < n.

The bound n ≥ 13 is sharp: F(12) = 144 = 2⁴·3², and both 2 | F(3)
and 3 | F(4), so no primitive divisor exists for n = 12.

## Proof Structure
- **Entry point theory:** We prove that checking primitivity reduces to
  checking proper divisors of n, using the strong divisibility property
  `gcd(F(m), F(n)) = F(gcd(m,n))` (Nat.fib_gcd in Mathlib).
- **Computational verification:** A verified GCD-based algorithm checks
  all composite n ∈ [13, 50000] via `native_decide`.
- **Asymptotic case:** For n > 50000, the primitive part Φ_n ≈ φ^{φ(n)}
  grows exponentially faster than n, guaranteeing a primitive prime divisor.
  This case requires the Lifting-the-Exponent Lemma for Fibonacci sequences
  (Carmichael 1913), which is stated but not yet formally verified.
-/
import Mathlib

set_option maxHeartbeats 1600000

/-! ## Entry Point Theory -/

/-- If p divides both F(k) and F(n), then p divides F(gcd(k,n)).
    Follows from the strong divisibility `F(gcd(m,n)) = gcd(F(m), F(n))`. -/
lemma prime_dvd_fib_gcd {p k n : ℕ} (hp : Nat.Prime p)
    (hk : p ∣ Nat.fib k) (hn : p ∣ Nat.fib n) :
    p ∣ Nat.fib (Nat.gcd k n) := by
  exact Nat.dvd_gcd hk hn |> fun h => by simpa [Nat.fib_gcd] using h

/-- Checking primitivity over all 0 < k < n is equivalent to
    checking only proper divisors d | n with 0 < d < n.
    This uses `Nat.fib_gcd` to show that if p | F(k) and p | F(n),
    then p | F(gcd(k,n)), and gcd(k,n) is a proper divisor of n. -/
lemma fib_primitive_iff_divisors {n : ℕ} (hn : 0 < n) {p : ℕ} (hp : Nat.Prime p)
    (hpn : p ∣ Nat.fib n) :
    (∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k)) ↔
    (∀ d, d ∣ n → 0 < d → d < n → ¬(p ∣ Nat.fib d)) := by
  refine ⟨fun h d hd _ _ ↦ h d ‹_› ‹_›, fun h k hk hk' ↦ ?_⟩
  exact fun hk'' => h (Nat.gcd k n) (Nat.gcd_dvd_right _ _)
    (Nat.gcd_pos_of_pos_left _ hk)
    (lt_of_le_of_lt (Nat.le_of_dvd hk (Nat.gcd_dvd_left _ _)) hk')
    (prime_dvd_fib_gcd hp hk'' hpn)

/-! ## Verified Computational Checker -/

/-- List of proper divisors of n (d with 0 < d < n and d | n). -/
def properDivs (n : ℕ) : List ℕ :=
  (List.range n).filter (fun d => 0 < d ∧ n % d = 0)

lemma mem_properDivs {n d : ℕ} :
    d ∈ properDivs n ↔ d < n ∧ 0 < d ∧ d ∣ n := by
  simp +decide [properDivs, Nat.dvd_iff_mod_eq_zero]

/-- Compute the "primitive residual" of F(n): iteratively divide out
    gcd with F(d) for each proper divisor d of n.
    If the result R > 1, then R has a prime factor that is primitive. -/
def primitiveResidual (n : ℕ) : ℕ :=
  let fn := Nat.fib n
  if fn ≤ 1 then 0
  else
    let divs := properDivs n
    Id.run do
      let mut rem := fn
      for _ in List.range 200 do
        let mut changed := false
        for d in divs do
          let g := Nat.gcd rem (Nat.fib d)
          if g > 1 then
            rem := rem / g
            changed := true
        if !changed then break
      return rem

/-- Verify that R certifies a primitive prime divisor:
    R > 1, R | F(n), and gcd(R, F(d)) = 1 for all proper divisors d. -/
def verifyResidual (n R : ℕ) : Bool :=
  (R > 1) &&
  (Nat.fib n % R == 0) &&
  (properDivs n).all (fun d => Nat.gcd R (Nat.fib d) == 1)

/-- Combined check: compute residual and verify. -/
def checkPrimitiveExistence (n : ℕ) : Bool :=
  verifyResidual n (primitiveResidual n)

/-- Range check for all composite n in [lo, hi]. -/
def checkRangePrimitive (lo hi : ℕ) : Bool :=
  (List.range (hi - lo + 1)).all (fun i =>
    let n := lo + i
    Nat.Prime n || checkPrimitiveExistence n)

/-! ## Soundness -/

/-- If `verifyResidual` returns true, then F(n) has a primitive prime divisor.
    The proof: R > 1 gives a prime factor p of R. Since R | F(n), p | F(n).
    Since gcd(R, F(d)) = 1 for proper divisors d, p ∤ F(d).
    By `fib_primitive_iff_divisors`, p is a primitive prime divisor. -/
lemma verifyResidual_sound {n R : ℕ} (hn : 0 < n)
    (h : verifyResidual n R = true) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  obtain ⟨p, hp_prime, hp_div_R⟩ : ∃ p : ℕ, Nat.Prime p ∧ p ∣ R := by
    exact Nat.exists_prime_and_dvd (by unfold verifyResidual at h; aesop)
  refine' ⟨p, hp_prime, _, _⟩
  · exact dvd_trans hp_div_R (Nat.dvd_of_mod_eq_zero (by unfold verifyResidual at h; aesop))
  · intro k hk hk'; simp_all +decide [verifyResidual]
    contrapose! h
    refine' fun h => ⟨Nat.gcd k n, _, _⟩ <;> simp_all +decide [mem_properDivs]
    · exact ⟨lt_of_le_of_lt (Nat.le_of_dvd hk (Nat.gcd_dvd_left _ _)) hk', Nat.gcd_dvd_right _ _⟩
    · rw [Nat.Prime.not_coprime_iff_dvd]
      exact ⟨p, hp_prime, hp_div_R, prime_dvd_fib_gcd hp_prime ‹p ∣ Nat.fib k›
        (hp_div_R.trans (Nat.dvd_of_mod_eq_zero h.2))⟩

/-- If `checkPrimitiveExistence` returns true, F(n) has a primitive prime divisor. -/
lemma checkPrimitiveExistence_sound {n : ℕ} (hn : 0 < n)
    (h : checkPrimitiveExistence n = true) :
    ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) :=
  verifyResidual_sound hn h

/-- Soundness of the range checker. -/
lemma checkRangePrimitive_sound {lo hi : ℕ} (hlo : 0 < lo)
    (h : checkRangePrimitive lo hi = true) :
    ∀ n, lo ≤ n → n ≤ hi → ¬Nat.Prime n →
      ∃ p, Nat.Prime p ∧ p ∣ Nat.fib n ∧ ∀ k, 0 < k → k < n → ¬(p ∣ Nat.fib k) := by
  unfold checkRangePrimitive at h
  simp_all +decide [List.all_eq_true]
  intro n hn₁ hn₂ hn₃
  specialize h (n - lo) (Nat.sub_le_sub_right hn₂ _)
  rcases h with (h | h) <;> simp_all +decide [add_tsub_cancel_of_le hn₁]
  exact checkPrimitiveExistence_sound (by linarith) h

/-! ## Computational Verification

The GCD-based primitive residual algorithm is efficient enough that
`native_decide` can verify all composite n in [13, 50000].
-/

/-- Verified: all composite n ∈ [13, 50000] have a primitive prime divisor of F(n). -/
theorem fib_primitive_le_50000 : checkRangePrimitive 13 50000 = true := by native_decide

/-! ## Asymptotic case (n > 50000)

For composite n > 50000, the existence of a primitive prime divisor
follows from the Lifting-the-Exponent Lemma (LTE) for Fibonacci numbers:
for odd prime p with p | F(m) and entry point z(p) = m,

  v_p(F(m·k)) = v_p(F(m)) + v_p(k)
-- ... (truncated, full file has 184 lines)
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
