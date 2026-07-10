import Mathlib

/-!
# Erdős's lower bound on the diagonal Ramsey numbers

Erdős's 1947 paper introduced the *probabilistic method* to prove that the diagonal Ramsey
number `R(k,k)` grows at least exponentially: `R(k,k) > 2^{k/2}`. The proof is a counting
argument (equivalently, a first-moment computation): among the `2^{binom(n,2)}` two-colourings
of the edges of `K_n`, fewer than `2^{binom(n,2)}` contain a monochromatic `K_k`, so a good
colouring must exist.

We carry out the counting argument directly over `Finset`s (no measure theory needed), which
makes it fully constructive.

## Main declarations

* `ErdosRamsey.Arrows n k` : the arrow relation `n → (k,k)` — every red/blue edge colouring of
  `K_n` contains a monochromatic `K_k`.
* `ErdosRamsey.not_arrows_of_two_mul_choose_lt` : the counting theorem — if
  `2 * (n.choose k) < 2 ^ (k.choose 2)` then `¬ Arrows n k`, i.e. `R(k,k) > n`.
* `ErdosRamsey.not_arrows_pow` : the explicit Erdős bound `R(k,k) > 2^{k/2}` (for `k ≥ 3`),
  stated as `¬ Arrows (2 ^ (k / 2)) k`.
* concrete instances such as `ErdosRamsey.not_arrows_5_4` (`R(4,4) > 5`, giving `R(4,4) ≥ 6`).
-/

open Finset

namespace ErdosRamsey

variable {n : ℕ}

/-- The edge set of the complete graph induced on a vertex set `S`:
the unordered pairs of *distinct* vertices lying in `S`. -/
def edgesWithin (S : Finset (Fin n)) : Finset (Sym2 (Fin n)) :=
  S.sym2.filter (fun e => ¬ e.IsDiag)

/-- A vertex set `S` is *monochromatic* under an edge colouring `c` if all the edges inside `S`
receive the same colour. -/
def IsMono (c : Sym2 (Fin n) → Bool) (S : Finset (Fin n)) : Prop :=
  ∃ b, ∀ e ∈ edgesWithin S, c e = b

/-- The arrow relation `n → (k,k)` : every two-colouring of the edges of `K_n` (a function
`Sym2 (Fin n) → Bool`) has a monochromatic clique on some `k`-element vertex set. -/
def Arrows (n k : ℕ) : Prop :=
  ∀ c : Sym2 (Fin n) → Bool, ∃ S ∈ (univ.powersetCard k : Finset (Finset (Fin n))), IsMono c S

/-
The number of internal edges of a `k`-set is `k choose 2`.
-/
theorem card_edgesWithin (S : Finset (Fin n)) :
    (edgesWithin S).card = S.card.choose 2 := by
  convert Finset.card_powersetCard 2 S using 1;
  refine' Finset.card_bij ( fun x hx => Finset.univ.filter fun y => y ∈ x ) _ _ _;
  · simp +decide [ edgesWithin, Sym2.forall ];
    simp +contextual [ Finset.subset_iff, Finset.filter_eq', Finset.filter_or ];
  · simp +contextual [ Finset.ext_iff, Sym2.ext_iff ];
  · simp +decide [ edgesWithin ];
    intro b hb hb'; obtain ⟨ x, y, hxy ⟩ := Finset.card_eq_two.mp hb'; use Sym2.mk ( x, y ) ; aesop;

/-- **Union-bound count.** The number of colourings that are monochromatic on a fixed vertex
set `S` is at most `2 * 2^{N - binom(|S|,2)}`, where
`N = |E(K_n)|` is the total number of edges. Indeed such a colouring is determined by the single
common colour on the edges of `S` together with its values on all edges outside `S`.
-/
theorem card_filter_isMono_le [DecidableEq (Fin n)]
    (S : Finset (Fin n))
    [DecidablePred (fun c : Sym2 (Fin n) → Bool => IsMono c S)] :
    (univ.filter (fun c : Sym2 (Fin n) → Bool => IsMono c S)).card
      ≤ 2 * 2 ^ (Fintype.card (Sym2 (Fin n)) - S.card.choose 2) := by
  have h_card : ∀ b : Bool, (Finset.card (Finset.filter (fun c : Sym2 (Fin n) → Bool => ∀ e ∈ edgesWithin S, c e = b) (Finset.univ : Finset (Sym2 (Fin n) → Bool)))) ≤ 2 ^ (Fintype.card (Sym2 (Fin n)) - (S.card.choose 2)) := by
    intro b
    have h_card : (Finset.card (Finset.filter (fun c : Sym2 (Fin n) → Bool => ∀ e ∈ edgesWithin S, c e = b) (Finset.univ : Finset (Sym2 (Fin n) → Bool)))) ≤ Finset.card (Finset.image (fun c : Sym2 (Fin n) → Bool => fun e : {e : Sym2 (Fin n) // e ∉ edgesWithin S} => c e.val) (Finset.filter (fun c : Sym2 (Fin n) → Bool => ∀ e ∈ edgesWithin S, c e = b) (Finset.univ : Finset (Sym2 (Fin n) → Bool)))) := by
      rw [ Finset.card_image_of_injOn ];
      intro c₁ hc₁ c₂ hc₂ h_eq; ext e; by_cases he : e ∈ edgesWithin S <;> simp_all +decide [ funext_iff ] ;
    refine le_trans h_card <| le_trans ( Finset.card_le_univ _ ) ?_;
    simp +decide [ card_edgesWithin ];
  convert le_trans _ ( add_le_add ( h_card Bool.true ) ( h_card Bool.false ) ) using 1;
  · ring;
  · convert Finset.card_union_le _ _ using 2;
    ext c; simp [IsMono];
    · tauto;
    · infer_instance

/-
**Erdős's counting theorem.** If `2 * (n.choose k) < 2 ^ (k.choose 2)` then `K_n` admits a
two-colouring with no monochromatic `K_k`; equivalently `¬ Arrows n k`, i.e. `R(k,k) > n`.
-/
theorem not_arrows_of_two_mul_choose_lt (k : ℕ) (hk : 2 ≤ k) (hkn : k ≤ n)
    (h : 2 * n.choose k < 2 ^ (k.choose 2)) : ¬ Arrows n k := by
  contrapose! h;
  -- By definition of $Arrows$, we know that every coloring of the edges of $K_n$ contains a monochromatic $K_k$.
  have h_coloring : ∀ c : Sym2 (Fin n) → Bool, ∃ S ∈ Finset.powersetCard k (Finset.univ : Finset (Fin n)), IsMono c S := by
    exact h;
  choose f hf₁ hf₂ using h_coloring;
  -- For each $k$-set $S$, let $E_S$ be the set of colorings for which $S$ is monochromatic.
  set E : Finset (Finset (Fin n)) := Finset.powersetCard k (Finset.univ : Finset (Fin n))
  set ES : Finset (Finset (Sym2 (Fin n))) := E.image (fun S => edgesWithin S);
  -- By definition of $ES$, we know that for each $S \in E$, $|ES| \leq 2 \cdot 2^{N - \binom{k}{2}}$, where $N = \binom{n}{2}$.
  have h_card_ES : ∀ S ∈ ES, (Finset.filter (fun c : Sym2 (Fin n) → Bool => ∀ e ∈ S, c e = true) (Finset.univ : Finset (Sym2 (Fin n) → Bool))).card + (Finset.filter (fun c : Sym2 (Fin n) → Bool => ∀ e ∈ S, c e = false) (Finset.univ : Finset (Sym2 (Fin n) → Bool))).card ≤ 2 * 2 ^ (Fintype.card (Sym2 (Fin n)) - S.card) := by
    intros S hS
    have h_card_ES : (Finset.filter (fun c : Sym2 (Fin n) → Bool => ∀ e ∈ S, c e = true) (Finset.univ : Finset (Sym2 (Fin n) → Bool))).card ≤ 2 ^ (Fintype.card (Sym2 (Fin n)) - S.card) := by
      have h_card_ES : (Finset.filter (fun c : Sym2 (Fin n) → Bool => ∀ e ∈ S, c e = true) (Finset.univ : Finset (Sym2 (Fin n) → Bool))).card ≤ Finset.card (Finset.image (fun c : Sym2 (Fin n) → Bool => fun e => if e ∈ S then true else c e) (Finset.univ : Finset (Sym2 (Fin n) → Bool))) := by
        refine Finset.card_le_card ?_;
        grind;
      refine le_trans h_card_ES ?_;
      refine' le_trans ( Finset.card_le_card _ ) _;
      exact Finset.image ( fun c : { e : Sym2 ( Fin n ) // e ∉ S } → Bool => fun e => if h : e ∈ S then true else c ⟨ e, h ⟩ ) ( Finset.univ : Finset ( { e : Sym2 ( Fin n ) // e ∉ S } → Bool ) );
      · simp +decide [ Finset.subset_iff ];
        exact fun c => ⟨ fun e => c e, by ext e; by_cases he : e ∈ S <;> simp +decide [ he ] ⟩;
      · refine' Finset.card_image_le.trans _;
        simp +decide [ Finset.card_univ ];
    convert add_le_add h_card_ES h_card_ES using 1;
    · rw [ Finset.card_filter, Finset.card_filter ];
      rw [ ← Equiv.sum_comp ( Equiv.addRight ( fun _ => Bool.true ) ) ] ; aesop;
    · ring;
  -- Therefore, the total number of colorings is at most $\sum_{S \in ES} 2 \cdot 2^{N - \binom{k}{2}}$.
  have h_total_card : (Finset.univ : Finset (Sym2 (Fin n) → Bool)).card ≤ ∑ S ∈ ES, 2 * 2 ^ (Fintype.card (Sym2 (Fin n)) - S.card) := by
    have h_total_card : (Finset.univ : Finset (Sym2 (Fin n) → Bool)).card ≤ ∑ S ∈ ES, (Finset.filter (fun c : Sym2 (Fin n) → Bool => ∀ e ∈ S, c e = true) (Finset.univ : Finset (Sym2 (Fin n) → Bool))).card + ∑ S ∈ ES, (Finset.filter (fun c : Sym2 (Fin n) → Bool => ∀ e ∈ S, c e = false) (Finset.univ : Finset (Sym2 (Fin n) → Bool))).card := by
      have h_total_card : ∀ c : Sym2 (Fin n) → Bool, ∃ S ∈ ES, (∀ e ∈ S, c e = true) ∨ (∀ e ∈ S, c e = false) := by
        intro c
        obtain ⟨S, hS⟩ := hf₂ c
        use edgesWithin (f c);
        grind;
      have h_total_card : (Finset.univ : Finset (Sym2 (Fin n) → Bool)) ⊆ Finset.biUnion ES (fun S => Finset.filter (fun c : Sym2 (Fin n) → Bool => ∀ e ∈ S, c e = true) (Finset.univ : Finset (Sym2 (Fin n) → Bool)) ∪ Finset.filter (fun c : Sym2 (Fin n) → Bool => ∀ e ∈ S, c e = false) (Finset.univ : Finset (Sym2 (Fin n) → Bool))) := by
        intro c hc; specialize h_total_card c; aesop;
      exact le_trans ( Finset.card_le_card h_total_card ) ( Finset.card_biUnion_le.trans ( Finset.sum_le_sum fun x hx => Finset.card_union_le _ _ ) ) |> le_trans <| by simp +decide [ Finset.sum_add_distrib ] ;
    exact h_total_card.trans ( by simpa only [ ← Finset.sum_add_distrib ] using Finset.sum_le_sum h_card_ES );
  -- Since $|ES| \leq \binom{n}{k}$, we have $\sum_{S \in ES} 2 \cdot 2^{N - \binom{k}{2}} \leq \binom{n}{k} \cdot 2 \cdot 2^{N - \binom{k}{2}}$.
  have h_sum_card : ∑ S ∈ ES, 2 * 2 ^ (Fintype.card (Sym2 (Fin n)) - S.card) ≤ (Nat.choose n k) * 2 * 2 ^ (Fintype.card (Sym2 (Fin n)) - Nat.choose k 2) := by
    have h_sum_card : ∀ S ∈ ES, 2 * 2 ^ (Fintype.card (Sym2 (Fin n)) - S.card) ≤ 2 * 2 ^ (Fintype.card (Sym2 (Fin n)) - Nat.choose k 2) := by
      simp +zetaDelta at *;
      intro a ha; rw [ card_edgesWithin a ] ; aesop;
    refine' le_trans ( Finset.sum_le_sum h_sum_card ) _;
    simp +zetaDelta at *;
    exact le_trans ( Nat.mul_le_mul_right _ ( Finset.card_image_le ) ) ( by simp +decide [ mul_assoc, Finset.card_univ ] );
  simp_all +decide [ Finset.card_univ ];
  have h_exp : 2 ^ Fintype.card (Sym2 (Fin n)) = 2 ^ (Fintype.card (Sym2 (Fin n)) - Nat.choose k 2) * 2 ^ Nat.choose k 2 := by
    rw [ ← pow_add, Nat.sub_add_cancel ];
    rw [ Sym2.card ];
    exact Nat.choose_le_choose _ ( by simpa using by linarith );
  nlinarith [ pow_pos ( zero_lt_two' ℕ ) ( Fintype.card ( Sym2 ( Fin n ) ) - Nat.choose k 2 ) ]

/-
If there are fewer than `k` vertices there is no `k`-clique to be monochromatic, so
`Arrows n k` fails trivially.
-/
theorem not_arrows_of_lt (k : ℕ) (hnk : n < k) : ¬ Arrows n k := by
  intro h
  obtain ⟨S, hS⟩ := h (fun _ => true);
  exact absurd ( Finset.mem_powersetCard.mp hS.1 |>.2 ) ( by linarith [ show S.card ≤ n from le_trans ( Finset.card_le_univ _ ) ( by norm_num ) ] )

/-
Elementary exponent inequality used below: `⌊k/2⌋ · k ≤ binom(k,2) + ⌊k/2⌋`. It is an
equality for even `k` and has slack for odd `k`.
-/
theorem half_mul_self_le (k : ℕ) : (k / 2) * k ≤ k.choose 2 + k / 2 := by
  rcases Nat.even_or_odd' k with ⟨ k, rfl | rfl ⟩ <;> simp +arith +decide [ Nat.choose ];
  · induction k <;> simp +arith +decide [ Nat.choose, Nat.mul_succ ] at *;
    lia;
  · induction k <;> simp +arith +decide [ Nat.choose ] at *;
    norm_num [ Nat.add_div ] at * ; nlinarith

/-
A factorial lower bound: `2^{⌊k/2⌋ + 1} < k!` for `k ≥ 3`.
-/
theorem two_pow_half_succ_lt_factorial (k : ℕ) (hk : 3 ≤ k) :
    2 ^ (k / 2 + 1) < k.factorial := by
  -- We'll use induction. The base case is when $k = 4$.
  induction' k using Nat.strong_induction_on with k ih;
  rcases hk with ( _ | _ | k ) <;> simp +arith +decide [ Nat.factorial_succ, pow_succ' ] at *;
  grind +splitImp

/-
The number-theoretic heart of the explicit bound: for `k ≥ 3` and `n = 2^{k/2}` (integer
part), `2 * (n.choose k) < 2 ^ (k.choose 2)`.
-/
theorem two_mul_choose_pow_lt (k : ℕ) (hk : 3 ≤ k) :
    2 * (2 ^ (k / 2)).choose k < 2 ^ (k.choose 2) := by
  -- Let $n := 2 ^ (k / 2)$ and $d := k.choose 2$.
  set n := 2 ^ (k / 2)
  set d := k.choose 2;
  -- Using the factorial identity and the descending factorial bound, we get `k! * (2 * n.choose k) ≤ 2 * n^k`.
  have h_factorial : k.factorial * (2 * n.choose k) ≤ 2 * n ^ k := by
    nlinarith [ Nat.descFactorial_eq_factorial_mul_choose n k, Nat.descFactorial_le_pow n k ];
  -- By `half_mul_self_le k : (k/2) * k ≤ d + k / 2`, we get `(k/2)*k + 1 ≤ d + (k/2 + 1)`, hence
  have h_exp : 2 * n ^ k ≤ 2 ^ (d + (k / 2 + 1)) := by
    rw [ ← pow_mul ];
    rw [ ← pow_succ' ] ; exact pow_le_pow_right₀ ( by decide ) ( by linarith [ half_mul_self_le k ] ) ;
  -- By `two_pow_half_succ_lt_factorial k hk : 2 ^ (k/2 + 1) < k!`, and since `0 < 2 ^ d`, we get
  have h_final : 2 ^ (d + (k / 2 + 1)) < k.factorial * 2 ^ d := by
    convert Nat.mul_lt_mul_of_pos_right ( two_pow_half_succ_lt_factorial k hk ) ( pow_pos ( by decide : ( 0 : ℕ ) < 2 ) d ) using 1 ; ring;
  nlinarith [ Nat.factorial_pos k ]

/-- **Erdős's lower bound `R(k,k) > 2^{k/2}`** (for `k ≥ 3`), stated as the failure of the
arrow relation at `n = 2^{k/2}`. -/
theorem not_arrows_pow (k : ℕ) (hk : 3 ≤ k) : ¬ Arrows (2 ^ (k / 2)) k := by
  rcases le_or_gt k (2 ^ (k / 2)) with hkn | hnk
  · exact not_arrows_of_two_mul_choose_lt (n := 2 ^ (k / 2)) k (by omega) hkn
      (two_mul_choose_pow_lt k hk)
  · exact not_arrows_of_lt (n := 2 ^ (k / 2)) k hnk

/-- Concrete instance: `R(4,4) > 5`, i.e. there is a red/blue colouring of `K_5` with no
monochromatic `K_4`. -/
theorem not_arrows_5_4 : ¬ Arrows 5 4 :=
  not_arrows_of_two_mul_choose_lt 4 (by norm_num) (by norm_num) (by decide)

/-- Concrete instance: `R(6,6) > 8 = 2^{6/2}`. -/
theorem not_arrows_8_6 : ¬ Arrows 8 6 :=
  not_arrows_of_two_mul_choose_lt 6 (by norm_num) (by norm_num) (by decide)

end ErdosRamsey