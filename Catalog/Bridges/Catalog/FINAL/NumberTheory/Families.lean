/-
# Erdős–Straus Conjecture: Infinite Parametric Families

This file proves that the Erdős–Straus conjecture holds for several
infinite families of integers, each corresponding to a congruence class.

## Families proved here

1. **Even numbers** (n ≡ 0 mod 2): 4/(2k) = 1/k + 1/(2k) + 1/(2k)
2. **n ≡ 3 mod 4**: 4/n = 1/x + 1/(2xn) + 1/(2xn) where x = (n+1)/4
3. **n ≡ 0 mod 3**: 4/n = 1/(n/3) + 1/(2n) + 1/(2n)
4. **n ≡ 2 mod 3**: 4/n = 1/n + 1/((n+1)/3) + 1/(n·(n+1)/3)

Together these cover all integers not congruent to 1 mod 12, which is
a set of density 11/12 among all positive integers ≥ 2.
-/
import Speculative.ErdosStraus.Defs

/-- **Theorem A: Even-denominator family.**
For every k ≥ 1, the identity 4/(2k) = 1/k + 1/(2k) + 1/(2k) gives
an Erdős–Straus decomposition. This is the simplest infinite family. -/
theorem erdos_straus_even (k : ℕ) (hk : 1 ≤ k) :
    ErdosStrausSolvable (2 * k) := by
  refine ⟨k, 2 * k, 2 * k, ?_⟩
  exact ⟨ hk, by positivity, by positivity, by push_cast; ring ⟩

/-
**Theorem B: Family n ≡ 3 mod 4.**
For n = 4k+3, set x = k+1 = (n+1)/4, then
4/n = 1/x + 1/(2xn) + 1/(2xn).
Proof: 1/x + 2/(2xn) = 1/x + 1/(xn) = (n+1)/(xn) = 4(k+1)/((k+1)(4k+3)) = 4/n.
-/
theorem erdos_straus_mod4_eq3 (n : ℕ)
    (hn : 2 ≤ n) (hmod : n % 4 = 3) :
    ErdosStrausSolvable n := by
  refine ⟨(n + 1) / 4, 2 * ((n + 1) / 4) * n, 2 * ((n + 1) / 4) * n, ?_⟩
  constructor <;> norm_num;
  · omega;
  · exact ⟨ ⟨ by omega, by omega ⟩, by nlinarith [ Nat.div_mul_cancel ( show 4 ∣ n + 1 from Nat.dvd_of_mod_eq_zero ( by norm_num [ Nat.add_mod, hmod ] ) ), pow_pos ( Nat.div_pos ( show n + 1 ≥ 4 by omega ) zero_lt_four ) 2, pow_pos ( Nat.div_pos ( show n + 1 ≥ 4 by omega ) zero_lt_four ) 3 ] ⟩

/-
**Theorem C: Family n ≡ 0 mod 3.**
For n = 3m, set x = m = n/3, y = z = 2n.
Then 4/n = 1/m + 1/(2·3m) + 1/(2·3m) = 1/m + 1/(6m) + 1/(6m)
     = (6 + 1 + 1)/(6m) = 8/(6m)... wait, let me recheck.
Actually 1/m + 1/(6m) + 1/(6m) = (6+1+1)/(6m) = 8/(6m) = 4/(3m) = 4/n. ✓
-/
theorem erdos_straus_mod3_eq0 (n : ℕ)
    (hn : 2 ≤ n) (hmod : n % 3 = 0) :
    ErdosStrausSolvable n := by
  refine ⟨n / 3, 2 * n, 2 * n, ?_⟩
  exact ⟨ Nat.div_pos ( Nat.le_of_dvd ( by positivity ) ( Nat.dvd_of_mod_eq_zero hmod ) ) ( by norm_num ), by positivity, by positivity, by norm_cast; nlinarith [ Nat.div_mul_cancel ( Nat.dvd_of_mod_eq_zero hmod ) ] ⟩

/-
**Theorem D: Family n ≡ 2 mod 3.**
For n ≡ 2 mod 3, 3|(n+1). Set m = (n+1)/3, then
4/n = 1/n + 3/n = 1/n + 1/m + 1/(nm).
Proof: 1/m + 1/(nm) = (n+1)/(nm) = 3m/(nm) = 3/n. ✓
-/
theorem erdos_straus_mod3_eq2 (n : ℕ)
    (hn : 2 ≤ n) (hmod : n % 3 = 2) :
    ErdosStrausSolvable n := by
  refine ⟨n, (n + 1) / 3, n * ((n + 1) / 3), ?_⟩
  constructor <;> norm_num;
  · linarith;
  · rw [ ← Nat.mod_add_div n 3, hmod ] ; ring_nf ; norm_cast;
    norm_num [ Nat.add_div ] ; ring

/-
**Synthesis: Large covered set.**
The union of four families covers all n ≥ 2 except n ≡ 1 mod 12
(odd, ≡ 1 mod 4, ≡ 1 mod 3). This gives density 11/12 coverage.
-/
theorem erdos_straus_large_covered_set (n : ℕ) (hn : 2 ≤ n)
    (h : n % 2 = 0 ∨ n % 3 = 0 ∨ n % 3 = 2 ∨ n % 4 = 3) :
    ErdosStrausSolvable n := by
  rcases h with ( h | h | h | h );
  · exact erdos_straus_even ( n / 2 ) ( by linarith [ Nat.mod_add_div n 2 ] ) |> fun ⟨ x, y, z, h ⟩ => ⟨ x, y, z, by rwa [ show n = 2 * ( n / 2 ) by linarith [ Nat.mod_add_div n 2 ] ] ⟩;
  · exact erdos_straus_mod3_eq0 n hn h
  · exact erdos_straus_mod3_eq2 n hn h
  · exact erdos_straus_mod4_eq3 n hn h