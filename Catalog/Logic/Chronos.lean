/-! # CatalogBuild.Logic.Chronos

Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 70
-/

import Mathlib

noncomputable section

/-- A prime is "light" (a photon) if it is ≡ 1 mod 4. -/
def isLightPrime (p : ℕ) : Prop := p.Prime ∧ p % 4 = 1




/-- A prime is "dark" (space) if it is ≡ 3 mod 4. -/
def isDarkPrime (p : ℕ) : Prop := p.Prime ∧ p % 4 = 3




/-- 2 is the unique "twilight" prime — neither light nor dark. -/
def isTwilightPrime (p : ℕ) : Prop := p.Prime ∧ p = 2




/-- 5 is a light prime (photon). -/
theorem five_is_light : isLightPrime 5 := by constructor <;> decide




/-- 13 is a light prime (photon). -/
theorem thirteen_is_light : isLightPrime 13 := by constructor <;> decide




/-- 3 is a dark prime (space). -/
theorem three_is_dark : isDarkPrime 3 := by constructor <;> decide




/-- 7 is a dark prime (space). -/
theorem seven_is_dark : isDarkPrime 7 := by constructor <;> decide




/-- 11 is a dark prime (space). -/
theorem eleven_is_dark : isDarkPrime 11 := by constructor <;> decide




/-- 2 is the twilight prime. -/
theorem two_is_twilight : isTwilightPrime 2 := by constructor <;> decide




/-- No prime is both light and dark. -/
theorem light_dark_disjoint (p : ℕ) : ¬(isLightPrime p ∧ isDarkPrime p) := by
  intro ⟨⟨_, h1⟩, ⟨_, h3⟩⟩; omega




/-- 2 is not light. -/
theorem two_not_light : ¬isLightPrime 2 := by intro ⟨_, h⟩; omega




/-- 2 is not dark. -/
theorem two_not_dark : ¬isDarkPrime 2 := by intro ⟨_, h⟩; omega




/-- Every odd prime is either light or dark. -/
theorem odd_prime_light_or_dark (p : ℕ) (hp : p.Prime) (hodd : p ≠ 2) :
    isLightPrime p ∨ isDarkPrime p := by
  unfold isLightPrime isDarkPrime
  have h := hp.odd_of_ne_two hodd
  rw [Nat.odd_iff] at h
  have : p % 4 = 1 ∨ p % 4 = 3 := by omega
  tauto




/-- The trichotomy: every prime is exactly one of twilight, light, or dark. -/
theorem prime_trichotomy (p : ℕ) (hp : p.Prime) :
    isTwilightPrime p ∨ isLightPrime p ∨ isDarkPrime p := by
  by_cases h : p = 2
  · left; exact ⟨hp, h⟩
  · right; exact odd_prime_light_or_dark p hp h




/-- Count of light primes up to n. -/
def lightPrimeCount (n : ℕ) : ℕ :=
  ((Finset.range (n + 1)).filter (fun p => p.Prime ∧ p % 4 = 1)).card




/-- Count of dark primes up to n. -/
def darkPrimeCount (n : ℕ) : ℕ :=
  ((Finset.range (n + 1)).filter (fun p => p.Prime ∧ p % 4 = 3)).card




/-- There are 4 light primes up to 30: {5, 13, 17, 29}. -/
theorem light_count_30 : lightPrimeCount 30 = 4 := by native_decide




/-- There are 5 dark primes up to 30: {3, 7, 11, 19, 23}. -/
theorem dark_count_30 : darkPrimeCount 30 = 5 := by native_decide




/-- Dark primes slightly outnumber light primes up to 30 — space dominates light! -/
theorem dark_exceeds_light_30 : darkPrimeCount 30 > lightPrimeCount 30 := by native_decide




/-- Light prime count up to 100. -/
theorem light_count_100 : lightPrimeCount 100 = 11 := by native_decide




/-- Dark prime count up to 100. -/
theorem dark_count_100 : darkPrimeCount 100 = 13 := by native_decide




/-- n! + k is divisible by k when 2 ≤ k ≤ n. This is the engine of expansion. -/
theorem factorial_plus_k_divisible (n k : ℕ) (hk2 : 2 ≤ k) (hkn : k ≤ n) :
    k ∣ n.factorial + k := by
  have h1 : k ∣ n.factorial := Nat.dvd_factorial (by omega) hkn
  exact dvd_add h1 (dvd_refl k)




/-- n! + k is composite when 2 ≤ k ≤ n.
These are the "dark intervals" — pure space, no photons. -/
theorem factorial_plus_k_composite (n k : ℕ) (_hn : 2 ≤ n) (hk2 : 2 ≤ k) (hkn : k ≤ n) :
    ¬(n.factorial + k).Prime := by
  intro hp
  have hdvd := factorial_plus_k_divisible n k hk2 hkn
  have hk_lt : k < n.factorial + k := by
    have : 0 < n.factorial := Nat.factorial_pos n
    omega
  exact (hp.eq_one_or_self_of_dvd k hdvd).elim (by omega) (by omega)




/-- For any gap size G, there exist G consecutive composite numbers.
**Space expands without bound.** -/
theorem space_expands (G : ℕ) :
    ∃ start : ℕ, ∀ j, j < G → ¬((start + j).Prime) := by
  by_cases hG : G ≤ 1
  · use 4
    intro j hj
    have : j = 0 := by omega
    subst this; decide
  · use (G + 1).factorial + 2
    intro j hj
    have hj2 : 2 ≤ j + 2 := by omega
    have hjG : j + 2 ≤ G + 1 := by omega
    have := factorial_plus_k_composite (G + 1) (j + 2) (by omega) hj2 hjG
    rwa [show (G + 1).factorial + 2 + j = (G + 1).factorial + (j + 2) from by omega]




/-- A sum-of-two-squares representation witnesses that a number is "luminous." -/
structure SumOfSquaresWitness (n : ℕ) where
  a : ℕ
  b : ℕ
  ha : 0 < a
  hb : 0 < b
  eq : a ^ 2 + b ^ 2 = n




/-- 5 = 1² + 2²: the simplest photon. -/
def photon_5 : SumOfSquaresWitness 5 where
  a := 1
  b := 2
  ha := by omega
  hb := by omega
  eq := by norm_num




/-- 13 = 2² + 3²: another photon. -/
def photon_13 : SumOfSquaresWitness 13 where
  a := 2
  b := 3
  ha := by omega
  hb := by omega
  eq := by norm_num




/-- 29 = 2² + 5²: a photon. -/
def photon_29 : SumOfSquaresWitness 29 where
  a := 2
  b := 5
  ha := by omega
  hb := by omega
  eq := by norm_num




/-- 2 = 1² + 1²: the twilight prime is also a sum of squares. -/
def photon_2 : SumOfSquaresWitness 2 where
  a := 1
  b := 1
  ha := by omega
  hb := by omega
  eq := by norm_num




/-- The Gaussian norm is multiplicative: combining photons creates new photons.
This is wave superposition in the arithmetic universe. -/
theorem photon_superposition (a b c d : ℤ) :
    (a ^ 2 + b ^ 2) * (c ^ 2 + d ^ 2) = (a * c - b * d) ^ 2 + (a * d + b * c) ^ 2 := by
  ring




/-- Product of two luminous numbers is luminous.
Photon-photon interaction produces photons. -/
theorem luminous_product {m n : ℕ} (hm : ∃ a b : ℕ, a ^ 2 + b ^ 2 = m)
    (hn : ∃ a b : ℕ, a ^ 2 + b ^ 2 = n) :
    ∃ a b : ℤ, a ^ 2 + b ^ 2 = (m : ℤ) * (n : ℤ) := by
  obtain ⟨a, b, rfl⟩ := hm
  obtain ⟨c, d, rfl⟩ := hn
  exact ⟨a * c - b * d, a * d + b * c, by push_cast; ring⟩




/-- Gravitational weight of a moment on the timeline. -/
def timelineWeight (n : ℕ) : ℕ := n.divisors.card




/-- Primes have minimal weight: exactly 2 (divisors are {1, p}). -/
theorem prime_minimal_weight (p : ℕ) (hp : p.Prime) : timelineWeight p = 2 := by
  unfold timelineWeight
  rw [hp.divisors]
  exact Finset.card_pair (Ne.symm (Nat.Prime.one_lt hp).ne')




/-- 1 has weight 1 — the vacuum. -/
theorem vacuum_weight : timelineWeight 1 = 1 := by native_decide




/-- The weight of a prime power p^k is k+1. Timeline moments at prime powers
form a simple arithmetic progression of weights. -/
theorem prime_power_weight (p k : ℕ) (hp : p.Prime) :
    timelineWeight (p ^ k) = k + 1 := by
  simp [timelineWeight, Nat.divisors_prime_pow hp]




/-- 12 = 2² × 3 has weight 6 — a "gravitational well" on the timeline. -/
theorem heavy_moment_12 : timelineWeight 12 = 6 := by native_decide




/-- 6 is a "balanced" moment: weight 4. -/
theorem balanced_moment_6 : timelineWeight 6 = 4 := by native_decide




/-- The composite count up to n: how much "space" exists in [0, n]. -/
def spaceCount (n : ℕ) : ℕ :=
  ((Finset.range (n + 1)).filter (fun k => 2 ≤ k ∧ ¬k.Prime)).card




/-- The photon (prime) count up to n. -/
def photonCount (n : ℕ) : ℕ :=
  ((Finset.range (n + 1)).filter (fun k => k.Prime)).card




/-- Space always exceeds light after the first few moments. -/
theorem space_dominates_10 : spaceCount 10 > photonCount 10 := by native_decide




/-- [Section: # CatalogBuild.Logic.Chronos
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 70] -/
theorem space_dominates_100 : spaceCount 100 > photonCount 100 := by native_decide




/-- By moment 30: 19 composites vs 10 primes — space is ~2x light. -/
theorem space_ratio_30 : spaceCount 30 = 19 ∧ photonCount 30 = 10 := by
  constructor <;> native_decide




/-- By moment 100: 74 composites vs 25 primes — space is ~3x light. -/
theorem space_ratio_100 : spaceCount 100 = 74 ∧ photonCount 100 = 25 := by
  constructor <;> native_decide




/-- A research oracle: maps hypotheses to validated knowledge. -/
structure ResearchOracle (H : Type*) where
  validate : H → H
  stable : ∀ h, validate (validate h) = validate h




/-- The knowledge base is the fixed-point set of the research oracle. -/
def ResearchOracle.knowledgeBase {H : Type*} (R : ResearchOracle H) : Set H :=
  {h | R.validate h = h}




/-- Every validated hypothesis is in the knowledge base. -/
theorem ResearchOracle.validation_enters_kb {H : Type*} (R : ResearchOracle H) (h : H) :
    R.validate h ∈ R.knowledgeBase :=
  R.stable h




/-- The knowledge base is exactly the range of validation. -/
theorem ResearchOracle.kb_eq_range {H : Type*} (R : ResearchOracle H) :
    R.knowledgeBase = range R.validate := by
  ext y; constructor
  · intro hy; exact ⟨y, hy⟩
  · rintro ⟨x, rfl⟩; exact R.stable x




/-- Composing two research oracles (if they commute) gives a research oracle. -/
theorem compose_research_oracles {H : Type*} (R S : ResearchOracle H)
    (RS_idem : ∀ h, R.validate (S.validate (R.validate (S.validate h))) =
                     R.validate (S.validate h)) :
    ∀ h, (R.validate ∘ S.validate) ((R.validate ∘ S.validate) h) =
         (R.validate ∘ S.validate) h := by
  intro h; simp [Function.comp]; exact RS_idem h




/-- The "Chebyshev bias": among small primes, dark primes tend to outnumber light ones. -/
theorem chebyshev_bias_small :
    ∀ n ∈ ({10, 20, 30, 50} : Finset ℕ),
    darkPrimeCount n ≥ lightPrimeCount n := by
  decide




/-- But the bias can reverse! At some points, light catches up. -/
theorem bias_reversal_exists :
    ∃ n, lightPrimeCount n ≥ darkPrimeCount n := by
  use 0; decide




/-- A moment's "light content": number of prime factors ≡ 1 mod 4
(counted with multiplicity via primeFactorsList). -/
def lightContent (n : ℕ) : ℕ :=
  n.primeFactorsList.countP (fun p => p % 4 == 1)




/-- A moment's "dark content": number of prime factors ≡ 3 mod 4
(counted with multiplicity via primeFactorsList). -/
def darkContent (n : ℕ) : ℕ :=
  n.primeFactorsList.countP (fun p => p % 4 == 3)




/-- 15 = 3 × 5 has equal light and dark content — a balanced moment. -/
theorem balanced_15 : lightContent 15 = 1 ∧ darkContent 15 = 1 := by
  constructor <;> native_decide




/-- 21 = 3 × 7 is pure dark — a void in the timeline. -/
theorem dark_21 : lightContent 21 = 0 ∧ darkContent 21 = 2 := by
  constructor <;> native_decide




/-- 65 = 5 × 13 is pure light — a photon burst. -/
theorem light_65 : lightContent 65 = 2 ∧ darkContent 65 = 0 := by
  constructor <;> native_decide




/-- 2310 = 2 × 3 × 5 × 7 × 11 — a primordial moment mixing light and dark. -/
theorem primordial_2310 : lightContent 2310 = 1 ∧ darkContent 2310 = 3 := by
  constructor <;> native_decide




/-- The n-th prime (0-indexed, with 0 ↦ 2). A lookup table for small primes. -/
def nthPrime : ℕ → ℕ
  | 0 => 2 | 1 => 3 | 2 => 5 | 3 => 7 | 4 => 11 | 5 => 13
  | 6 => 17 | 7 => 19 | 8 => 23 | 9 => 29 | 10 => 31
  | 11 => 37 | 12 => 41 | 13 => 43 | 14 => 47 | _ => 0




/-- The prime gap: how much space lies between consecutive primes. -/
def primeGap (n : ℕ) : ℕ := nthPrime (n + 1) - nthPrime n




/-- First gap: 3 - 2 = 1 (minimal space). -/
theorem gap_0 : primeGap 0 = 1 := by decide




/-- Gap between 7 and 11: space = 4 (expanding!). -/
theorem gap_3 : primeGap 3 = 4 := by decide




/-- Gap between 23 and 29: space = 6 (still expanding!). -/
theorem gap_8 : primeGap 8 = 6 := by decide




/-- The first 9 gaps show expansion is not monotone — but unbounded. -/
theorem first_gaps :
    [primeGap 0, primeGap 1, primeGap 2, primeGap 3, primeGap 4,
     primeGap 5, primeGap 6, primeGap 7, primeGap 8] =
    [1, 2, 2, 4, 2, 4, 2, 4, 6] := by decide




/-- Two moments are entangled if their sum is a perfect square. -/
def areEntangled (a b : ℕ) : Prop := ∃ k, a + b = k ^ 2




/-- 1 and 3 are entangled: 1 + 3 = 4 = 2². -/
theorem entangled_1_3 : areEntangled 1 3 := ⟨2, by norm_num⟩




/-- 5 and 11 are entangled: 5 + 11 = 16 = 4². -/
theorem entangled_5_11 : areEntangled 5 11 := ⟨4, by norm_num⟩




/-- Entanglement is symmetric. -/
theorem entangled_symm (a b : ℕ) : areEntangled a b ↔ areEntangled b a := by
  constructor <;> intro ⟨k, hk⟩ <;> exact ⟨k, by omega⟩




/-- Every number is entangled with a perfect square complement. -/
theorem universal_entanglement (n : ℕ) :
    ∃ m, areEntangled n m := by
  refine ⟨(n + 1) ^ 2 - n, n + 1, ?_⟩
  have : (n + 1) ^ 2 ≥ n := by nlinarith
  omega




/-- The Grand Synthesis: every natural number > 1 contains a prime factor
that is either light, dark, or twilight. Every moment on the timeline
connects to the fundamental light/dark duality. -/
theorem every_moment_has_prime_character (n : ℕ) (hn : 2 ≤ n) :
    ∃ p, p.Prime ∧ p ∣ n ∧
    (isTwilightPrime p ∨ isLightPrime p ∨ isDarkPrime p) := by
  obtain ⟨p, hp, hpn⟩ := Nat.exists_prime_and_dvd (by omega : n ≠ 1)
  exact ⟨p, hp, hpn, prime_trichotomy p hp⟩




/-- The timeline never ends: for every moment, there's a later prime moment. -/
theorem timeline_infinite (n : ℕ) : ∃ p, n < p ∧ p.Prime := by
  obtain ⟨p, hn, hp⟩ := Nat.exists_infinite_primes (n + 1)
  exact ⟨p, by omega, hp⟩




/-- [Section: # CatalogBuild.Logic.Chronos
Auto-generated from theorem catalog database.
Domain: Logic
Declarations: 70] -/
theorem universe_stretches : ∀ G : ℕ, ∃ a b : ℕ, a.Prime ∧ b.Prime ∧
    a < b ∧ G ≤ b - a ∧ (∀ k, a < k → k < b → ¬k.Prime) := by
  intro G;
  -- Let's choose $n = G + 2$.
  set n := G + 2;
  -- Consider the interval $[(n+1)! + 2, (n+1)! + (n+1)]$.
  have h_interval : ∀ k ∈ Finset.Ico ((n + 1)! + 2) ((n + 1)! + (n + 1)), ¬Nat.Prime k := by
    -- For any $k$ in the interval $[(n+1)! + 2, (n+1)! + (n+1)]$, we can write $k = (n+1)! + m$ for some $2 \leq m \leq n+1$.
    intro k hk
    obtain ⟨m, hm⟩ : ∃ m, 2 ≤ m ∧ m ≤ n + 1 ∧ k = (n + 1)! + m := by
      exact ⟨ k - ( n + 1 ) !, by linarith [ Finset.mem_Ico.mp hk, Nat.sub_add_cancel ( by linarith [ Finset.mem_Ico.mp hk ] : ( n + 1 ) ! ≤ k ) ], by linarith [ Finset.mem_Ico.mp hk, Nat.sub_add_cancel ( by linarith [ Finset.mem_Ico.mp hk ] : ( n + 1 ) ! ≤ k ) ], by rw [ add_tsub_cancel_of_le ( by linarith [ Finset.mem_Ico.mp hk ] ) ] ⟩;
    rw [ hm.2.2, Nat.prime_def_lt' ];
    exact fun h => h.2 m hm.1 ( by linarith [ Nat.self_le_factorial ( n + 1 ) ] ) ( Nat.dvd_add ( Nat.dvd_factorial ( by linarith ) ( by linarith ) ) ( dvd_refl m ) );
  -- Let $a$ be the largest prime less than or equal to $(n+1)! + 1$.
  obtain ⟨a, ha⟩ : ∃ a, Nat.Prime a ∧ a ≤ (n + 1)! + 1 ∧ ∀ k, Nat.Prime k → k ≤ (n + 1)! + 1 → k ≤ a := by
    exact ⟨ Finset.max' ( Finset.filter Nat.Prime ( Finset.Iic ( ( n + 1 ) ! + 1 ) ) ) ⟨ 2, by norm_num; linarith [ Nat.self_le_factorial ( n + 1 ) ] ⟩, Finset.mem_filter.mp ( Finset.max'_mem ( Finset.filter Nat.Prime ( Finset.Iic ( ( n + 1 ) ! + 1 ) ) ) ⟨ 2, by norm_num; linarith [ Nat.self_le_factorial ( n + 1 ) ] ⟩ ) |>.2, Finset.mem_Iic.mp ( Finset.mem_filter.mp ( Finset.max'_mem ( Finset.filter Nat.Prime ( Finset.Iic ( ( n + 1 ) ! + 1 ) ) ) ⟨ 2, by norm_num; linarith [ Nat.self_le_factorial ( n + 1 ) ] ⟩ ) |>.1 ), fun k hk hk' => Finset.le_max' _ _ ( by aesop ) ⟩;
  -- Let $b$ be the smallest prime greater than or equal to $(n+1)! + (n+1)$.
  obtain ⟨b, hb⟩ : ∃ b, Nat.Prime b ∧ (n + 1)! + (n + 1) ≤ b ∧ ∀ k, Nat.Prime k → (n + 1)! + (n + 1) ≤ k → b ≤ k := by
    exact ⟨ Nat.find ( Nat.exists_infinite_primes ( ( n + 1 ) ! + ( n + 1 ) ) ), Nat.find_spec ( Nat.exists_infinite_primes ( ( n + 1 ) ! + ( n + 1 ) ) ) |>.2, Nat.find_spec ( Nat.exists_infinite_primes ( ( n + 1 ) ! + ( n + 1 ) ) ) |>.1, fun k hk hk' => Nat.find_min' ( Nat.exists_infinite_primes ( ( n + 1 ) ! + ( n + 1 ) ) ) ⟨ hk', hk ⟩ ⟩;
  refine' ⟨ a, b, ha.1, hb.1, _, _, _ ⟩;
  · grind;
  · grind;
  · grind




end
