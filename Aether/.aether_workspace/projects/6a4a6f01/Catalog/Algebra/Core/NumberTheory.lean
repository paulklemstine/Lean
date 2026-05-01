import Mathlib

/-! # CatalogBuild.Algebra.Core.NumberTheory

Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 5
-/


/-- [Section: # CatalogBuild.Algebra.Core.NumberTheory
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 5] -/
theorem prime_dvd_mul (p a b : ℕ) (hp : p.Prime) (h : p ∣ a * b) :
    p ∣ a ∨ p ∣ b := by
      exact hp.dvd_mul.mp h




/-- [Section: # CatalogBuild.Algebra.Core.NumberTheory
Auto-generated from theorem catalog database.
Domain: Algebra/Core
Declarations: 5] -/
theorem euler_theorem (a n : ℕ) (hn : 0 < n) (hcoprime : Nat.Coprime a n) :
    a ^ n.totient ≡ 1 [MOD n] := by
      exact?




theorem factor_from_sum_diff (p q : ℕ) (hp : 0 < p) (hq : 0 < q) (hpq : q ≤ p) :
    p * q = ((p + q) ^ 2 - (p - q) ^ 2) / 4 := by
      exact Eq.symm ( Nat.div_eq_of_eq_mul_left zero_lt_four ( Nat.sub_eq_of_eq_add <| by nlinarith only [ Nat.sub_add_cancel hpq ] ) )




theorem prime_gaps_unbounded : ∀ k : ℕ, ∃ n : ℕ,
    (∀ i : ℕ, i ∈ Finset.range k → ¬(n + 1 + i).Prime) := by
      intro k;
      -- Now consider the sequence of numbers $n! + 2, n! + 3, ..., n! + (k+1)$.
      -- Each of these numbers is composite since $n! + i$ is divisible by $i$ for $2 \leq i \leq k+1$.
      have h_composite : ∀ i ∈ Finset.range k, ¬Nat.Prime (Nat.factorial (k + 1) + 2 + i) := by
        intro i hi; rw [ show ( k + 1 |> Nat.factorial ) + 2 + i = ( i + 2 ) * ( ( k + 1 |> Nat.factorial ) / ( i + 2 ) + 1 ) by linarith [ Nat.div_mul_cancel ( show i + 2 ∣ ( k + 1 |> Nat.factorial ) from Nat.dvd_factorial ( by linarith [ Finset.mem_range.mp hi ] ) ( by linarith [ Finset.mem_range.mp hi ] ) ) ] ] ; exact Nat.not_prime_mul ( by linarith [ Finset.mem_range.mp hi ] ) ( by linarith [ Finset.mem_range.mp hi, Nat.div_pos ( show ( k + 1 |> Nat.factorial ) ≥ i + 2 from Nat.le_of_dvd ( Nat.factorial_pos _ ) <| Nat.dvd_factorial ( by linarith [ Finset.mem_range.mp hi ] ) ( by linarith [ Finset.mem_range.mp hi ] ) ) ( by linarith [ Finset.mem_range.mp hi ] : 0 < i + 2 ) ] ) ;
      use Nat.factorial ( k + 1 ) + 1




theorem neg_one_qr_iff (p : ℕ) (hp : p.Prime) (hp2 : p ≠ 2) :
    (∃ x : ZMod p, x ^ 2 = -1) ↔ p % 4 = 1 := by
      constructor <;> intro h;
      · obtain ⟨ x, hx ⟩ := h;
        haveI := Fact.mk hp; have := ZMod.exists_sq_eq_neg_one_iff ( p := p ) ; simp_all +decide [ ← ZMod.intCast_eq_intCast_iff ] ;
        exact this.mp ⟨ x, by rw [ sq ] at hx; aesop ⟩ |> fun h => by have := Nat.Prime.eq_two_or_odd hp; omega;
      · haveI := Fact.mk hp; norm_num at *;
        obtain ⟨ x, hx ⟩ := ZMod.exists_sq_eq_neg_one_iff ( p := p );
        exact Exists.elim ( hx ( by rw [ h ] ; decide ) ) fun x hx => ⟨ x, by rw [ sq, hx ] ⟩



