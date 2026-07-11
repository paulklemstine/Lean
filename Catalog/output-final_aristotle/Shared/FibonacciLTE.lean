import Mathlib

/-! # A lifting-the-exponent law for Fibonacci numbers

For a Fibonacci number `F`, and an odd prime `p` that already divides `F m`, the
`p`-adic valuation of `F (m·p)` is exactly one more than that of `F m`:
`v_p(F (m·p)) = v_p(F m) + 1`.  This is the Fibonacci analogue of the classical
lifting-the-exponent lemma, and it is the arithmetic engine controlling how prime
powers propagate along the Fibonacci sequence.

The route goes through an exact binomial expansion of a Fibonacci number at a
multiple of its index.  Writing `α` for the golden ratio (so `α² = α + 1` and
`α^{m+1} = F(m+1)·α + F m`), raising to the `n`-th power and reading off the
`α`-coefficient — the two coefficients of `{1, α}` are independent because `α` is
irrational — yields the identity

  `F((m+1)·n) = ∑_{j=0}^{n} C(n, j) · F(m)^{n-j} · F(m+1)^j · F(j)`.

Specialising `n` to an odd prime `p`, every term except the `j = 1` term is
divisible by `p^{v+2}` (where `v = v_p(F m)`): the interior binomial coefficients
carry a factor `p`, and the powers `F(m)^j` for `j ≥ 2` contribute at least `2v`.
The `j = 1` term equals `p · F(m-1)^{p-1} · F m`, whose valuation is exactly
`v + 1` because `F(m-1)` is coprime to `F m` and hence to `p`.  Thus the whole sum
has valuation exactly `v + 1`.

-- !-- Lab Notes -- !--
* **Hypothesis (Hypothesizer).**  Prime powers in a strong divisibility sequence
  should climb by exactly one each time the index is multiplied by the prime,
  mirroring the lifting-the-exponent law for `a^n - b^n`.
* **Experiment (Experimenter).**  The linchpin was the exact multiple-index
  binomial expansion `fib_mul_binom`, obtained from the golden-ratio identity
  `α^{m+1} = F(m+1)·α + F m` and the binomial theorem, with coefficients read off
  via irrationality of `α`.  The valuation bookkeeping then isolates a single
  dominant term.
* **Analysis (Analyst).**  "True and structural."  The odd-prime hypothesis is
  essential: for `p = 2` the doubling identity `F(2k) = F(k)·L(k)` makes the
  valuation jump by more than one, so the `j = 1` term is no longer the unique
  minimiser.
* **Critique (Critic).**  Corner cases: `m = 1` needs `F(m-1) = F 0 = 0` handled
  by the coprimality step (`p ∤ F(m-1)` still holds since `F 0 = 0` is impossible
  under `p ∣ F 1 = 1`, which never occurs — so the live range is `m ≥ 2`, and
  `m = 1` is vacuous because `p ∣ F 1` fails).  The proof only uses `p ∣ F m`.
* **Synthesis (PI).**  This is the exact-valuation input required by the primitive
  divisor (Carmichael/Zsigmondy) theory for Fibonacci numbers: it pins the
  multiplicity of an intrinsic prime in the primitive part to one.
-/

set_option maxHeartbeats 1000000

open Finset in
/-- **Multiple-index binomial expansion.**  A Fibonacci number at a product index
expands as a binomial-type sum in two consecutive Fibonacci numbers:
`F((m+1)·n) = ∑_{j≤n} C(n,j) · F(m)^{n-j} · F(m+1)^j · F(j)`. -/
lemma fib_mul_binom (m n : ℕ) :
    Nat.fib ((m + 1) * n) =
      ∑ j ∈ Finset.range (n + 1),
        n.choose j * Nat.fib m ^ (n - j) * Nat.fib (m + 1) ^ j * Nat.fib j := by
  -- Let's set $a = F_m$ and $b = F_{m+1}$
  set a := Nat.fib m
  set b := Nat.fib (m + 1);
  -- Then $\phi^{(m+1)n} = (b \phi + a)^n$.
  have h_exp : (Real.goldenRatio : ℝ) ^ ((m + 1) * n) = (∑ j ∈ Finset.range (n + 1), Nat.choose n j * a ^ (n - j) * b ^ j * (Real.goldenRatio : ℝ) ^ j) := by
    have h_exp : (Real.goldenRatio : ℝ) ^ (m + 1) = b * Real.goldenRatio + a := by
      simp +zetaDelta at *;
      induction m <;> simp_all +decide [ pow_succ, Nat.fib_add_two ] ; ring;
      norm_num ; ring;
    rw [ pow_mul, h_exp, add_pow ];
    exact Finset.sum_congr rfl fun _ _ => by rw [ mul_pow ] ; ring;
  -- Equate the coefficients of $\phi$ on both sides of the equation.
  have h_coeff : (∑ j ∈ Finset.range (n + 1), Nat.choose n j * a ^ (n - j) * b ^ j * Nat.fib j : ℝ) = Nat.fib ((m + 1) * n) := by
    -- By definition of $F_k$, we know that $F_k = \frac{\phi^k - \psi^k}{\sqrt{5}}$, where $\psi = \frac{1 - \sqrt{5}}{2}$.
    have h_fib_formula : ∀ k : ℕ, (Nat.fib k : ℝ) = (Real.goldenRatio ^ k - (1 - Real.goldenRatio) ^ k) / Real.sqrt 5 := by
      intro k; induction' k using Nat.strong_induction_on with k ih; rcases k with ( _ | _ | k ) <;> norm_num [ Nat.fib_add_two ] at *;
      · ring_nf; norm_num;
      · grind;
    -- Similarly, we have $\psi^{(m+1)n} = (b \psi + a)^n$.
    have h_exp_psi : (1 - Real.goldenRatio : ℝ) ^ ((m + 1) * n) = (∑ j ∈ Finset.range (n + 1), Nat.choose n j * a ^ (n - j) * b ^ j * (1 - Real.goldenRatio : ℝ) ^ j) := by
      -- By definition of $a$ and $b$, we know that $b(1 - \phi) + a = (1 - \phi)^{m+1}$.
      have h_def : (b : ℝ) * (1 - Real.goldenRatio) + a = (1 - Real.goldenRatio) ^ (m + 1) := by
        simp +zetaDelta at *;
        induction m <;> simp_all +decide [ Nat.fib_add_two, pow_succ' ] ; ring;
        grind;
      rw [ pow_mul, h_def.symm, add_pow ] ; congr ; ext ; ring;
      rw [ show ( b : ℝ ) * ( 1 / 2 ) + b * Real.sqrt 5 * ( -1 / 2 ) = b * ( 1 / 2 + Real.sqrt 5 * ( -1 / 2 ) ) by ring ] ; rw [ mul_pow ] ; ring;
    simp_all +decide [ ← mul_assoc, ← Finset.sum_mul _ _ _ ];
    simp +decide only [mul_div, mul_sub];
    rw [ ← Finset.sum_sub_distrib, Finset.sum_div ];
  exact_mod_cast h_coeff.symm

/-- **Lifting-the-exponent for Fibonacci numbers.**  For an odd prime `p` and
`m ≥ 1` with `p ∣ F m`, the `p`-adic valuation of `F (m·p)` is one more than that
of `F m`. -/
lemma fib_lte_step (p m : ℕ) (hp : p.Prime) (hp2 : p ≠ 2) (hm : 1 ≤ m)
    (hdvd : p ∣ Nat.fib m) :
    (Nat.fib (m * p)).factorization p = (Nat.fib m).factorization p + 1 := by
  -- Let v = (Nat.fib m).factorization p. Since 1 ≤ m write m = (m-1)+1, and apply fib_mul_binom with base (m-1) and exponent p:
  set v := (Nat.fib m).factorization p
  have h1 : Nat.fib (m * p) = ∑ j ∈ Finset.range (p + 1), Nat.choose p j * Nat.fib (m - 1) ^ (p - j) * Nat.fib m ^ j * Nat.fib j := by
    convert fib_mul_binom ( m - 1 ) p using 1; all_goals rw [ Nat.sub_add_cancel hm ];
  -- Note fib((m-1)+1) = fib m. Analyze the p-adic valuation term by term. Let T j = C(p,j) · fib(m-1)^(p-j) · fib(m)^j · fib(j).
  have h2 : Nat.fib (m * p) ≡ p * Nat.fib (m - 1) ^ (p - 1) * Nat.fib m [MOD p ^ (v + 2)] := by
    -- For $2 \le j \le p-1$, $p \mid \binom{p}{j}$, so $v_p(\binom{p}{j}) \ge 1$, and $v_p(fib(m)^j) = j \cdot v \ge 2v \ge 2$. Hence $v_p(T_j) \ge 1 + 2v \ge v + 2$.
    have h3 : ∀ j ∈ Finset.Ico 2 p, p ^ (v + 2) ∣ Nat.choose p j * Nat.fib (m - 1) ^ (p - j) * Nat.fib m ^ j * Nat.fib j := by
      intro j hj
      have h_div : p ∣ Nat.choose p j := by
        exact hp.dvd_choose_self ( by linarith [ Finset.mem_Ico.mp hj ] ) ( by linarith [ Finset.mem_Ico.mp hj ] )
      have h_div_fib : p ^ (j * v) ∣ Nat.fib m ^ j := by
        simpa only [ pow_mul' ] using pow_dvd_pow_of_dvd ( Nat.ordProj_dvd _ _ ) _
      have h_div_fib_j : p ^ (v + 2) ∣ Nat.choose p j * Nat.fib m ^ j := by
        exact dvd_trans ( by rw [ ← pow_succ' ] ; exact pow_dvd_pow _ ( by nlinarith [ Finset.mem_Ico.mp hj, show v > 0 from Nat.pos_of_ne_zero ( Finsupp.mem_support_iff.mp ( by aesop ) ) ] ) ) ( mul_dvd_mul h_div h_div_fib );
      exact dvd_trans h_div_fib_j ( by exact ⟨ Nat.fib ( m - 1 ) ^ ( p - j ) * Nat.fib j, by ring ⟩ );
    -- For $j = p$, $C(p,p) = 1$, but $v_p(fib(m)^p) = p \cdot v \ge p \ge 3 \ge v + 2$ (since $(p-1)v \ge 2$). Hence $v_p(T_p) \ge v + 2$.
    have h4 : p ^ (v + 2) ∣ Nat.choose p p * Nat.fib (m - 1) ^ (p - p) * Nat.fib m ^ p * Nat.fib p := by
      have h4 : p ^ (v + 2) ∣ Nat.fib m ^ p := by
        have h4 : p ^ (v + 2) ∣ p ^ (p * v) := by
          exact pow_dvd_pow _ ( by nlinarith [ show p > 2 from lt_of_le_of_ne hp.two_le ( Ne.symm hp2 ), show v > 0 from Nat.pos_of_ne_zero ( Finsupp.mem_support_iff.mp ( by aesop ) ) ] );
        exact dvd_trans h4 ( by rw [ pow_mul' ] ; exact pow_dvd_pow_of_dvd ( Nat.ordProj_dvd _ _ ) _ );
      exact dvd_mul_of_dvd_left ( by simpa using h4 ) _;
    -- Therefore, in the sum exactly one term (j = 1) attains the minimal valuation v+1 and all others have valuation ≥ v+2; consequently the valuation of the total sum is exactly v+1.
    have h5 : ∑ j ∈ Finset.range (p + 1), Nat.choose p j * Nat.fib (m - 1) ^ (p - j) * Nat.fib m ^ j * Nat.fib j ≡ ∑ j ∈ Finset.range 2, Nat.choose p j * Nat.fib (m - 1) ^ (p - j) * Nat.fib m ^ j * Nat.fib j [MOD p ^ (v + 2)] := by
      rw [ ← Finset.sum_range_add_sum_Ico _ ( show 2 ≤ p + 1 from by linarith only [ hp.two_le ] ) ];
      norm_num [ Nat.modEq_iff_dvd ];
      exact_mod_cast Finset.dvd_sum fun x hx => if hx' : x = p then hx'.symm ▸ h4 else h3 x ( Finset.mem_Ico.mpr ⟨ Finset.mem_Ico.mp hx |>.1, lt_of_le_of_ne ( Finset.mem_Ico.mp hx |>.2 |> Nat.lt_succ_iff.mp ) hx' ⟩ );
    simp_all +decide [ Finset.sum_range_succ ];
  -- Since $p \mid Nat.fib m$, we have $p^{v+1} \mid Nat.fib (m * p)$ but $p^{v+2} \nmid Nat.fib (m * p)$.
  have h3 : p ^ (v + 1) ∣ Nat.fib (m * p) ∧ ¬(p ^ (v + 2) ∣ Nat.fib (m * p)) := by
    have h3 : p ^ (v + 1) ∣ p * Nat.fib (m - 1) ^ (p - 1) * Nat.fib m ∧ ¬(p ^ (v + 2) ∣ p * Nat.fib (m - 1) ^ (p - 1) * Nat.fib m) := by
      have h3 : Nat.gcd p (Nat.fib (m - 1)) = 1 := by
        refine hp.coprime_iff_not_dvd.mpr ?_;
        rcases m with ( _ | _ | m ) <;> simp_all +decide [ Nat.fib_add_two, Nat.dvd_add_right ];
        intro h; have := Nat.dvd_gcd hdvd h; simp_all +decide [ Nat.fib_add_two, Nat.Coprime, Nat.Coprime.gcd_eq_one ] ;
        exact absurd this ( by rw [ show Nat.gcd ( Nat.fib m ) ( Nat.fib ( m + 1 ) ) = 1 from by exact Nat.recOn m ( by norm_num ) fun n ih => by simp_all +decide [ Nat.fib_add_two, Nat.gcd_comm ] ] ; aesop );
      have h3 : p ^ (v + 1) ∣ p * Nat.fib m ∧ ¬(p ^ (v + 2) ∣ p * Nat.fib m) := by
        rw [ pow_succ', mul_dvd_mul_iff_left hp.ne_zero ];
        exact ⟨ Nat.ordProj_dvd _ _, by rw [ pow_succ', mul_dvd_mul_iff_left hp.ne_zero ] ; exact Nat.pow_succ_factorization_not_dvd ( Nat.ne_of_gt ( Nat.fib_pos.mpr hm ) ) hp ⟩;
      simp_all +decide [ mul_assoc, mul_comm, mul_left_comm, Nat.Prime.pow_dvd_iff_le_factorization ];
      simp_all +decide [ ← mul_assoc, Nat.Prime.pow_dvd_iff_le_factorization ];
      exact ⟨ dvd_mul_of_dvd_left h3.1 _, fun h => h3.2 <| Nat.Coprime.dvd_of_dvd_mul_right ( show Nat.Coprime ( p ^ ( v + 2 ) ) ( Nat.fib ( m - 1 ) ^ ( p - 1 ) ) from Nat.Coprime.pow _ _ <| by aesop ) h ⟩;
    exact ⟨ Nat.dvd_of_mod_eq_zero ( h2.of_dvd ( pow_dvd_pow _ ( Nat.le_succ _ ) ) ▸ Nat.modEq_zero_iff_dvd.mpr h3.1 ), fun h => h3.2 ( Nat.dvd_of_mod_eq_zero ( h2.symm.trans ( Nat.modEq_zero_iff_dvd.mpr h ) ) ) ⟩;
  obtain ⟨ k, hk ⟩ := h3.1;
  rw [ hk, Nat.factorization_mul ] <;> simp_all +decide [ hp.ne_zero ];
  · exact Nat.factorization_eq_zero_of_not_dvd fun h => h3.2 <| h1.symm ▸ mul_dvd_mul_left _ h;
  · rintro rfl; simp_all +decide [ Nat.fib_add_two ];
    exact absurd h1.symm ( ne_of_gt <| hk ▸ Nat.fib_pos.mpr ( Nat.mul_pos hm hp.pos ) )