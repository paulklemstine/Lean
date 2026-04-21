/-! # CatalogBuild.Speculative.EnergyLandscapeAdvanced

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 11
-/

import Mathlib

/-- Energy is zero iff x divides N. -/
theorem energy_zero_iff (N x : ℕ) (hx : 0 < x) : E N x = 0 ↔ x ∣ N := by
  unfold E; exact Nat.dvd_iff_mod_eq_zero.symm




/-- Energy is strictly less than x. -/
theorem energy_lt (N x : ℕ) (hx : 0 < x) : E N x < x :=
  Nat.mod_lt N hx




/-- [Section: # CatalogBuild.Speculative.EnergyLandscapeAdvanced
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 11] -/
theorem zero_energy_count (N : ℕ) (hN : 0 < N) :
    (Finset.Icc 1 N |>.filter (fun x => E N x = 0)).card = N.divisors.card := by
  refine' congr_arg _ _;
  -- By definition of $E$, we know that $E N x = 0$ if and only if $x$ divides $N$.
  ext x
  simp [E];
  exact ⟨ fun h => ⟨ Nat.dvd_of_mod_eq_zero h.2, hN.ne' ⟩, fun h => ⟨ ⟨ Nat.pos_of_dvd_of_pos h.1 hN, Nat.le_of_dvd hN h.1 ⟩, Nat.mod_eq_zero_of_dvd h.1 ⟩ ⟩




/-- [Section: # CatalogBuild.Speculative.EnergyLandscapeAdvanced
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 11] -/
theorem energy_predecessor (N : ℕ) (hN : 2 < N) : E N (N - 1) = 1 := by
  rcases N with ( _ | _ | _ | _ | _ | N ) <;> simp_all +arith +decide [ E ];
  norm_num [ ( by ring : N + 5 = N + 4 + 1 ) ]




/-- Energy at x = 2 classifies parity. -/
theorem energy_parity (N : ℕ) : E N 2 = N % 2 := by rfl




theorem total_energy_bound (N : ℕ) (hN : 0 < N) :
    ∑ x ∈ Finset.Icc 1 N, E N x ≤ N * N := by
  -- Each term $E(N,x) = N \mod x$ is less than $x$, so $\sum_{x=1}^N E(N,x) \le \sum_{x=1}^N x$.
  have h_term_bound : ∀ x ∈ Finset.Icc 1 N, E N x ≤ x := by
    exact fun x hx => Nat.le_of_lt <| Nat.mod_lt _ <| Finset.mem_Icc.mp hx |>.1;
  exact le_trans ( Finset.sum_le_sum h_term_bound ) ( by exact le_trans ( Finset.sum_le_sum fun x hx => Finset.mem_Icc.mp hx |>.2 ) ( by norm_num ) )




theorem average_energy_bound (N : ℕ) (hN : 1 ≤ N) :
    2 * (∑ x ∈ Finset.Icc 1 N, E N x) ≤ N * N * N := by
  induction hN <;> norm_num [ Finset.sum_Ioc_succ_top, (Nat.succ_eq_succ ▸ Finset.Icc_succ_left_eq_Ioc) ] at *;
  · native_decide +revert;
  · unfold E at *;
    norm_num [ Nat.mod_eq_of_lt ];
    exact le_trans ( mul_le_mul_of_nonneg_left ( Finset.sum_le_sum fun _ _ => Nat.mod_le _ _ ) zero_le_two ) ( by norm_num [ Finset.sum_add_distrib ] ; nlinarith )




theorem prime_two_zeros (N : ℕ) (hN : Nat.Prime N) :
    (Finset.Icc 1 N |>.filter (fun x => E N x = 0)).card = 2 := by
  convert zero_energy_count N hN.pos using 1;
  rw [ hN.divisors, Finset.card_insert_of_notMem ] <;> aesop




/-- The energy gradient: ΔE(x) = E(x+1) - E(x). -/
def energy_gradient (N x : ℕ) : ℤ := (E N (x + 1) : ℤ) - (E N x : ℤ)




theorem gradient_nonneg_at_factor (N d : ℕ) (hd : d ∣ N) (hd_pos : 0 < d)
    (hd_lt : d + 1 < N) :
    0 ≤ energy_gradient N d := by
  -- Since $d$ divides $N$, we have $E(N, d) = 0$.
  have h_ed : E N d = 0 := by
    exact Nat.mod_eq_zero_of_dvd hd;
  unfold energy_gradient; aesop;




theorem semiprime_minima_count (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) :
    (Finset.Icc 1 (p * q) |>.filter (fun x => E (p * q) x = 0)).card = 4 := by
  convert zero_energy_count ( p * q ) ( Nat.mul_pos hp.pos hq.pos ) using 1;
  -- The divisors of $pq$ are $1, p, q, pq$.
  have h_divisors : (p * q).divisors = {1, p, q, p * q} := by
    rw [ Nat.divisors_mul, hp.divisors, hq.divisors ];
    simpa [ Finset.ext_iff, Finset.mem_mul ] using by tauto;
  rw [ h_divisors, Finset.card_insert_of_notMem, Finset.card_insert_of_notMem, Finset.card_insert_of_notMem ] <;> norm_num [ hp.ne_zero, hq.ne_zero, hp.ne_one, hq.ne_one, hpq ];
  exact ⟨ Ne.symm hp.ne_one, Ne.symm hq.ne_one, Nat.ne_of_lt ( one_lt_mul'' hp.one_lt hq.one_lt ) ⟩


