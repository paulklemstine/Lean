import Mathlib

/-!
# 🧪 Algorithmic Evil — Mad Science with Numbers

## Oracle Council Research Log — Experiment #3

**Classification:** CHAOTIC EVIL — HANDLE WITH PROOF ASSISTANTS ONLY

**Discovery:** Some perfectly innocent-looking mathematical operations
harbor deep evil. Functions that LOOK computable but AREN'T. Sequences
that LOOK convergent but DON'T. Algorithms that LOOK efficient but
EXPLODE.

## The Mad Science Menu

1. **The Collatz Demon** — The simplest unsolvable problem
2. **Goodstein's Monster** — Always terminates, but you can't prove it (in PA)
3. **The Hydra of Lerna** — Cut one head, two grow back. You still win. Eventually.
4. **Ackermann's Growth Hormone** — Faster than any primitive recursive function

## Oracle Council Notes

- **Oracle Alpha:** "The Collatz function is three lines of code.
                     How hard can it be?"
- **Oracle Beta:** *weeps in undecidability*
- **Oracle Gamma:** "Ackermann grows so fast it escapes the concept of 'fast'."
- **Oracle Delta:** "Goodstein sequences reach numbers with more digits than
                     atoms in the universe, then suddenly drop to zero."
- **Oracle Omega (God):** "I made these to keep mathematicians humble."
-/

open Function Nat

namespace EvilMadScience.AlgorithmicEvil

/-! ### The Ackermann Monster

The Ackermann function grows faster than any primitive recursive function.
It's the mathematical equivalent of a monster that outgrows every cage. -/

/-- The Ackermann function: a total computable function that
    outgrows every primitive recursive function.
    A(0, n) = n + 1
    A(m+1, 0) = A(m, 1)
    A(m+1, n+1) = A(m, A(m+1, n))

    Evil property: A(4, 2) = 2^65536 - 3, which has ~19,729 digits. -/
def ackermann : ℕ → ℕ → ℕ
  | 0, n => n + 1
  | m + 1, 0 => ackermann m 1
  | m + 1, n + 1 => ackermann m (ackermann (m + 1) n)

/-
PROBLEM
Ackermann is strictly monotone in its second argument. The monster always grows.

PROVIDED SOLUTION
Use strictMono_nat_of_lt_succ. Need to show ackermann m n < ackermann m (n+1) for all n. Induction on m. Base m=0: ackermann 0 n = n+1 < n+2 = ackermann 0 (n+1). Step m+1: ackermann (m+1)(n+1) = ackermann m (ackermann (m+1) n). We need ackermann (m+1) n < ackermann (m+1)(n+1). By IH, ackermann m is strictly monotone. We have ackermann (m+1)(n+1) = ackermann m (ackermann (m+1) n). We need ackermann (m+1) n < ackermann m (ackermann (m+1) n). Since ackermann m k > k for all k (by ackermann_gt_right), we get ackermann m (ackermann (m+1) n) > ackermann (m+1) n.
-/
theorem ackermann_strict_mono_right (m : ℕ) : StrictMono (ackermann m) := by
  -- By definition of ackermann, we know that ackermann m n > n for all m and n.
  have h_ackermann_gt_right (m n : ℕ) : ackermann m n > n := by
    -- We'll use induction on $m$ to prove that $ackermann m n > n$ for all $n$.
    induction' m with m ih generalizing n;
    · -- The base case when $m = 0$ follows directly from the definition of the Ackermann function.
      simp [ackermann];
    · induction' n with n ih' <;> simp +arith +decide [ * ];
      · -- By definition of ackermann, we know that ackermann (m + 1) 0 = ackermann m 1.
        have h_ackermann_succ_zero : ackermann (m + 1) 0 = ackermann m 1 := by
          simp +zetaDelta at *;
          -- By definition of ackermann, we know that ackermann (m + 1) 0 = ackermann m 1. This follows directly from the definition of the Ackermann function.
          rw [ackermann];
        linarith [ ih 1 ];
      · -- We'll use that $ackermann (m + 1) (n + 1) = ackermann m (ackermann (m + 1) n)$.
        have h_rec : ackermann (m + 1) (n + 1) = ackermann m (ackermann (m + 1) n) := by
          rw [ackermann];
        linarith [ ih ( ackermann ( m + 1 ) n ) ];
  -- By induction on $m$, we can show that ackermann m is strictly monotone.
  induction' m with m ih;
  · exact strictMono_nat_of_lt_succ fun n => by simp +decide [ ackermann ] ;
  · refine' strictMono_nat_of_lt_succ fun n => _;
    -- By definition of ackermann, we have ackermann (m + 1) (n + 1) = ackermann m (ackermann (m + 1) n).
    have h_def : ackermann (m + 1) (n + 1) = ackermann m (ackermann (m + 1) n) := by
      rw [ackermann];
    linarith [ h_ackermann_gt_right m ( ackermann ( m + 1 ) n ) ]

/-
PROBLEM
Ackermann dominates its second argument. The monster is always bigger than its food.

PROVIDED SOLUTION
By induction on m and n. Base m=0: ackermann 0 n = n+1 > n. For m+1, 0: ackermann (m+1) 0 = ackermann m 1 > 1 > 0 by IH. For m+1, n+1: ackermann (m+1)(n+1) = ackermann m (ackermann (m+1) n) > ackermann (m+1) n > n by IH, so > n+1... hmm need to be more careful. Actually ackermann m k > k by IH on m, and ackermann (m+1) n > n by IH, so ackermann m (ackermann (m+1) n) > ackermann (m+1) n > n ≥ n, so > n. We need > n+1. We have ackermann (m+1) n > n so ackermann (m+1) n ≥ n+1, then ackermann m (ackermann (m+1) n) ≥ ackermann m (n+1) > n+1.
-/
theorem ackermann_gt_right (m n : ℕ) : ackermann m n > n := by
  induction' n with n ih generalizing m;
  · induction' m with m ih <;> simp +arith +decide [ * ];
    · native_decide +revert;
    · -- By definition of ackermann, we have ackermann (m + 1) 0 = ackermann m 1.
      rw [ackermann];
      exact Nat.one_le_iff_ne_zero.mpr ( by linarith [ ackermann_strict_mono_right m ( show 0 < 1 from by decide ) ] );
  · -- By the strict monotonicity of the Ackermann function in its second argument, we have ackermann m (n + 1) > ackermann m n.
    have h_mono : ackermann m (n + 1) > ackermann m n := by
      exact ackermann_strict_mono_right m ( Nat.lt_succ_self _ );
    linarith [ ih m ]

/-
PROBLEM
Ackermann base case computes correctly.

PROVIDED SOLUTION
Unfold ackermann. By definition, ackermann 0 n = n + 1.
-/
theorem ackermann_zero (n : ℕ) : ackermann 0 n = n + 1 := by
  -- By definition, we have `ackermann 1 m = ackermann (0+1) m = ackermann 0 1`.
  rw [ackermann]

/-
PROBLEM
A(1, n) = n + 2. Level 1 evil is just addition.

PROVIDED SOLUTION
By induction on n. Base: ackermann 1 0 = ackermann 0 1 = 2 = 0+2. Step: ackermann 1 (n+1) = ackermann 0 (ackermann 1 n) = ackermann 1 n + 1 = (n+2) + 1 = (n+1)+2 by IH.
-/
theorem ackermann_one (n : ℕ) : ackermann 1 n = n + 2 := by
  induction' n with n ih <;> simp +arith +decide [ *, ackermann ]

/-! ### The Pigeonhole Apocalypse

Any function from a larger finite type to a smaller one must have collisions.
This innocent fact powers: the birthday attack (cryptography), the pumping
lemma (formal languages), and Ramsey theory (combinatorics). -/

/-
PROBLEM
**The Pigeonhole Principle of Evil:**
    Inject n+2 pigeons into n+1 holes? Impossible. Someone shares a room.

PROVIDED SOLUTION
No injection from Fin (n+2) to Fin (n+1) because cardinality n+2 > n+1. Use Fintype.card_le_of_injective or Fin.injective_iff.
-/
theorem pigeonhole_evil (n : ℕ) (f : Fin (n + 2) → Fin (n + 1)) :
    ¬ Injective f := by
  exact fun h => absurd ( Fintype.card_le_of_injective f h ) ( by simp +arith +decide )

/-
PROBLEM
**The Birthday Paradox Setup:**
    In a group of n+1 people with only n possible birthdays,
    two people must share a birthday. Evil party planning.

PROVIDED SOLUTION
Since Fin (n+1) has n+1 elements and Fin n has n elements, f cannot be injective by pigeonhole. So there exist i ≠ j with f i = f j. Use Fintype.exists_ne_map_eq_of_card_lt or Function.not_injective.
-/
theorem birthday_collision (n : ℕ) (f : Fin (n + 1) → Fin n) :
    ∃ i j : Fin (n + 1), i ≠ j ∧ f i = f j := by
  by_contra h_contra
  push_neg at h_contra
  have h_card : Finset.card (Finset.image f (Finset.univ : Finset (Fin (n + 1)))) = n + 1 := by
    rw [ Finset.card_image_of_injective _ fun i j hij => not_imp_not.mp ( h_contra i j ) hij, Finset.card_fin ]
  have h_card_inv : Finset.card (Finset.image f (Finset.univ : Finset (Fin (n + 1)))) ≤ n := by
    exact le_trans ( Finset.card_le_univ _ ) ( by norm_num )
  linarith [h_card, h_card_inv]

/-! ### The Infinite Ramsey Doom

Among infinite disorder, order MUST emerge. You cannot escape pattern.
Even pure randomness, given enough space, crystallizes into structure.
This is the most terrifying theorem in combinatorics. -/

/-
PROBLEM
**Infinite Pigeonhole (The Doom Principle):**
    Any function from ℕ to a finite type must hit some value
    infinitely often. You cannot hide in finite clothing forever.

PROVIDED SOLUTION
By pigeonhole for infinite domain and finite codomain. Since Fin (n+1) is finite and ℕ is infinite, some fiber is infinite. Use Finset or Fintype pigeonhole. Specifically, if all fibers were finite, the preimage of the whole codomain would be finite, but it's ℕ. So some fiber is infinite, meaning for every N there exists m ≥ N with f m = c.
-/
theorem infinite_pigeonhole (n : ℕ) (f : ℕ → Fin (n + 1)) :
    ∃ c : Fin (n + 1), ∀ N : ℕ, ∃ m : ℕ, m ≥ N ∧ f m = c := by
  by_contra h_contra;
  -- By assumption, each value in Fin (n+1) is hit finitely often by f.
  have h_finite : ∀ c : Fin (n + 1), Set.Finite {m : ℕ | f m = c} := by
    exact fun c => Set.not_infinite.mp fun hi => h_contra ⟨ c, fun N => by rcases hi.exists_gt N with ⟨ m, hm₁, hm₂ ⟩ ; exact ⟨ m, hm₂.le, hm₁ ⟩ ⟩;
  exact Set.infinite_univ <| Set.Finite.subset ( Set.Finite.biUnion ( Set.toFinite ( Finset.univ : Finset ( Fin ( n + 1 ) ) ) ) fun c _ => h_finite c ) fun x hx => by aesop;

/-! ### The Fixed Point Inevitability

Some maps MUST have fixed points. You cannot escape yourself. -/

/-
PROBLEM
**Involutions Have Fixed Points on Odd Sets:**
    An involution on `Fin (2*n+1)` must fix at least one element.
    If the universe has an odd number of elements and every element
    is paired, someone is left alone. Existential horror via parity.

PROVIDED SOLUTION
An involution partitions the set into fixed points and 2-cycles. Since 2*n+1 is odd and 2-cycles contribute even elements, the number of fixed points must be odd, hence nonzero.
-/
theorem involution_odd_fixed_point (n : ℕ) (f : Fin (2 * n + 1) → Fin (2 * n + 1))
    (hf : ∀ x, f (f x) = x) : ∃ x, f x = x := by
  by_contra h;
  -- Since $f$ is an involution on a finite set, it must have an even number of elements in its domain.
  have h_even : Even (Finset.card (Finset.univ : Finset (Fin (2 * n + 1)))) := by
    -- Since $f$ is an involution, the set $Fin (2 * n + 1)$ can be partitioned into pairs $\{x, f(x)\}$.
    have h_partition : ∃ S : Finset (Finset (Fin (2 * n + 1))), (∀ s ∈ S, Finset.card s = 2) ∧ (∀ s ∈ S, ∀ t ∈ S, s ≠ t → Disjoint s t) ∧ (Finset.univ : Finset (Fin (2 * n + 1))) = Finset.biUnion S id := by
      refine' ⟨ Finset.image ( fun x => { x, f x } ) Finset.univ, _, _, _ ⟩ <;> simp_all +decide [ Finset.disjoint_left ];
      · exact fun x => Finset.card_pair ( Ne.symm ( h x ) );
      · grind +ring;
      · ext x; aesop;
    obtain ⟨ S, hS₁, hS₂, hS₃ ⟩ := h_partition; rw [ hS₃, Finset.card_biUnion ] <;> aesop;
  simp_all +decide [ Finset.card_univ ]

end EvilMadScience.AlgorithmicEvil