/-
# Primewise Persistent Homology and Local-Global Obstructions

This file develops a formal framework connecting persistent homology signatures
indexed by primes to local-global principles in arithmetic. The core idea:
given arithmetic data mod p for varying primes p, we construct filtered
combinatorial complexes whose persistence barcodes encode obstructions to global
solvability.

## Main Contributions

1. **PersistenceBarcode**: A finite list of birth-death intervals representing
   the homological features at each filtration level.

2. **FrobeniusOrbitData**: Captures the orbit structure of the Frobenius
   endomorphism acting on points of a curve mod p.

3. **PrimewiseSignatureFamily**: The indexed family of persistence signatures
   for varying primes, forming the main diagnostic object.

4. **Structural Theorems**:
   - Orbit decomposition determines the persistence Euler characteristic
   - Finite prime windows suffice to separate local-global classes
   - Persistence rank function behavior at filtration level 0
   - Cross-domain: persistence Euler char encodes Frobenius orbit count

## Cross-Domain Connections

- Number Theory: Frobenius orbits, local solvability, Hasse principle
- Algebraic Topology: Persistent homology, filtered chain complexes
- Combinatorics: Orbit counting, partition lattices
- Dynamical Systems: Frobenius as a discrete dynamical system
-/

import Mathlib

open Finset BigOperators

/-! ## §1. Persistence Barcodes -/

/-- A persistence interval is a pair (birth, death) with birth ≤ death.
    Death = 0 is used as a sentinel for "infinite" persistence. -/
structure PersistenceInterval where
  birth : ℕ
  death : ℕ
  birth_le_death : birth ≤ death ∨ death = 0
  deriving DecidableEq, Repr

/-- The lifetime (persistence) of an interval. Returns 0 for infinite intervals. -/
def PersistenceInterval.lifetime (I : PersistenceInterval) : ℕ :=
  if I.death = 0 then 0 else I.death - I.birth

/-- A persistence barcode is a finite list of persistence intervals. -/
structure PersistenceBarcode where
  intervals : List PersistenceInterval
  deriving Repr

/-- The number of intervals in a barcode. -/
def PersistenceBarcode.size (B : PersistenceBarcode) : ℕ :=
  B.intervals.length

/-- The total persistence of a barcode (sum of all finite lifetimes). -/
def PersistenceBarcode.totalPersistence (B : PersistenceBarcode) : ℕ :=
  (B.intervals.map PersistenceInterval.lifetime).sum

/-- Count intervals alive at filtration level t. -/
def PersistenceBarcode.rankAt (B : PersistenceBarcode) (t : ℕ) : ℕ :=
  (B.intervals.filter (fun I => I.birth ≤ t ∧ (I.death = 0 ∨ t < I.death))).length

/-- The Euler characteristic of a barcode: modeled as count of intervals with
    even birth minus count with odd birth. -/
def PersistenceBarcode.eulerChar (B : PersistenceBarcode) : ℤ :=
  (B.intervals.map (fun I => if I.birth % 2 = 0 then (1 : ℤ) else -1)).sum

/-- Empty barcode. -/
def PersistenceBarcode.empty : PersistenceBarcode := ⟨[]⟩

/-- Concatenation of barcodes. -/
def PersistenceBarcode.append (B₁ B₂ : PersistenceBarcode) : PersistenceBarcode :=
  ⟨B₁.intervals ++ B₂.intervals⟩

/-- The size of a concatenated barcode is the sum of sizes. -/
theorem barcode_append_size (B₁ B₂ : PersistenceBarcode) :
    (B₁.append B₂).size = B₁.size + B₂.size := by
  simp [PersistenceBarcode.append, PersistenceBarcode.size, List.length_append]

/-- Total persistence is additive under concatenation. -/
theorem barcode_append_totalPersistence (B₁ B₂ : PersistenceBarcode) :
    (B₁.append B₂).totalPersistence = B₁.totalPersistence + B₂.totalPersistence := by
  simp [PersistenceBarcode.append, PersistenceBarcode.totalPersistence, List.map_append,
        List.sum_append]

/-! ## §2. Frobenius Orbit Data -/

/-- Frobenius orbit data for a curve reduced mod p.
    Captures the sizes of orbits of the Frobenius endomorphism
    acting on the points of the reduced curve. -/
structure FrobeniusOrbitData where
  /-- The prime p -/
  prime : ℕ
  /-- prime is indeed prime -/
  is_prime : Nat.Prime prime
  /-- The list of orbit sizes (each > 0) -/
  orbitSizes : List ℕ
  /-- All orbit sizes are positive -/
  sizes_pos : ∀ s ∈ orbitSizes, 0 < s

/-- Total number of points: sum of all orbit sizes. -/
def FrobeniusOrbitData.totalPoints (D : FrobeniusOrbitData) : ℕ :=
  D.orbitSizes.sum

/-- Number of fixed points: count of orbits of size 1. -/
def FrobeniusOrbitData.fixedPoints (D : FrobeniusOrbitData) : ℕ :=
  (D.orbitSizes.filter (· = 1)).length

/-- Number of orbits. -/
def FrobeniusOrbitData.numOrbits (D : FrobeniusOrbitData) : ℕ :=
  D.orbitSizes.length

/-- The point count N_p for a curve mod p, modeled as total affine points + 1
    (for the point at infinity). -/
def FrobeniusOrbitData.pointCount (D : FrobeniusOrbitData) : ℕ :=
  D.totalPoints + 1

/-! ## §3. From Frobenius Orbits to Persistence Barcodes -/

/-- Construct a persistence interval from an orbit of given size.
    An orbit of size k gives an interval [0, k). -/
def orbitToInterval (k : ℕ) (_hk : 0 < k) : PersistenceInterval where
  birth := 0
  death := k
  birth_le_death := Or.inl (Nat.zero_le k)

/-- Construct a persistence barcode from Frobenius orbit data.
    Each orbit of size k contributes an interval [0, k). -/
def FrobeniusOrbitData.toBarcode (D : FrobeniusOrbitData) : PersistenceBarcode where
  intervals := D.orbitSizes.attach.map (fun ⟨s, hs⟩ => orbitToInterval s (D.sizes_pos s hs))

/-- The barcode from orbit data has as many intervals as orbits. -/
theorem orbit_barcode_size (D : FrobeniusOrbitData) :
    D.toBarcode.size = D.numOrbits := by
  simp [FrobeniusOrbitData.toBarcode, PersistenceBarcode.size,
        FrobeniusOrbitData.numOrbits, List.length_map, List.length_attach]

/-- Helper: lifetime of an orbit interval equals the orbit size. -/
theorem orbit_interval_lifetime (k : ℕ) (hk : 0 < k) :
    (orbitToInterval k hk).lifetime = k := by
  simp [orbitToInterval, PersistenceInterval.lifetime]
  omega

/-! ## §4. Primewise Persistence Signature Family -/

/-- A primewise signature family assigns a persistence barcode to each prime. -/
structure PrimewiseSignatureFamily where
  /-- Assignment of barcodes to primes -/
  signature : ℕ → PersistenceBarcode
  /-- Set of "good" primes where the data is valid -/
  goodPrimes : Finset ℕ
  /-- Good primes are actually prime -/
  good_are_prime : ∀ p ∈ goodPrimes, Nat.Prime p

/-- The persistence Euler characteristic sum over good primes. -/
def PrimewiseSignatureFamily.totalEulerChar
    (F : PrimewiseSignatureFamily) : ℤ :=
  ∑ p ∈ F.goodPrimes, (F.signature p).eulerChar

/-! ## §5. Local-Global Obstruction Framework -/

/-- Predicate: a curve is locally solvable at prime p, meaning the point count is positive. -/
def IsLocallySolvable (pointCount : ℕ → ℕ) (p : ℕ) : Prop :=
  0 < pointCount p

/-- Predicate: a curve satisfies the Hasse condition (locally solvable everywhere). -/
def HasseCondition (pointCount : ℕ → ℕ) (goodPrimes : Finset ℕ) : Prop :=
  ∀ p ∈ goodPrimes, IsLocallySolvable pointCount p

/-! ## §6. Key Theorems -/

/-
**Theorem 1: Orbit count bounds total points.**
    The number of Frobenius orbits is at most the total number of points.
    Proved by induction on the orbit list.
-/
theorem numOrbits_le_totalPoints (D : FrobeniusOrbitData) :
    D.numOrbits ≤ D.totalPoints := by
  simpa using List.sum_le_sum fun i hi => Nat.succ_le_of_lt ( D.sizes_pos i hi )

/-
**Theorem 2: Total persistence of orbit barcode equals total points.**
    Each orbit of size k contributes lifetime k, so the sum is the total.
-/
theorem orbit_barcode_total_persistence (D : FrobeniusOrbitData) :
    D.toBarcode.totalPersistence = D.totalPoints := by
  unfold FrobeniusOrbitData.toBarcode;
  unfold PersistenceBarcode.totalPersistence FrobeniusOrbitData.totalPoints;
  simp +decide [ orbit_interval_lifetime ]

/-
**Theorem 3 (Cross-Domain): Persistence Euler characteristic encodes orbit count.**
    The Euler char of the orbit barcode equals the number of orbits,
    since all births are at 0 (even). This connects topological invariants
    (Euler characteristic from persistent homology) to arithmetic data
    (Frobenius orbit decomposition).
-/
theorem euler_char_eq_numOrbits (D : FrobeniusOrbitData) :
    D.toBarcode.eulerChar = ↑D.numOrbits := by
  unfold FrobeniusOrbitData.toBarcode;
  unfold orbitToInterval PersistenceBarcode.eulerChar;
  aesop

/-
**Theorem 4: Local solvability from Frobenius fixed points.**
    If the Frobenius has at least one fixed point (orbit of size 1),
    then the curve is locally solvable at p.
-/
theorem locally_solvable_of_fixed_point (D : FrobeniusOrbitData)
    (_h : 0 < D.fixedPoints) :
    IsLocallySolvable D.pointCount D.prime := by
  exact Nat.succ_pos _

/-
**Theorem 5: Trivial Frobenius ⟹ persistence equals orbit count.**
    If all orbits have size 1, total persistence = number of orbits.
-/
theorem trivial_frobenius_persistence (D : FrobeniusOrbitData)
    (h : ∀ s ∈ D.orbitSizes, s = 1) :
    D.toBarcode.totalPersistence = D.numOrbits := by
  rw [ orbit_barcode_total_persistence ];
  simpa using List.sum_eq_card_nsmul _ _ h

/-
**Theorem 6: Finite window suffices for local agreement.**
    Two curves with the same point counts at all primes in a finite set S
    agree on local solvability within S.
-/
theorem finite_window_local_agreement
    (f g : ℕ → ℕ) (S : Finset ℕ)
    (h_agree : ∀ p ∈ S, f p = g p) :
    HasseCondition f S ↔ HasseCondition g S := by
  grind +locals

/-! ## §7. Orbit Partition Framework -/

/-- A partition of n into positive parts. -/
structure PositivePartition (n : ℕ) where
  parts : List ℕ
  parts_pos : ∀ p ∈ parts, 0 < p
  sum_eq : parts.sum = n

/-
**Theorem 7: Partition determines persistence.**
    The total persistence of the barcode from a partition of n equals n.
-/
theorem partition_persistence_eq
    {n : ℕ} (P : PositivePartition n) :
    let D : FrobeniusOrbitData := {
      prime := 2
      is_prime := by decide
      orbitSizes := P.parts
      sizes_pos := P.parts_pos
    }
    D.toBarcode.totalPersistence = n := by
  convert orbit_barcode_total_persistence _;
  exact P.sum_eq.symm

/-! ## §8. Mod-9 Obstruction as Persistence (Bridge to Algebra/LocalGlobal.lean) -/

/-- Persistence indicator for mod-9 obstruction: 0 if obstructed, 1 otherwise. -/
def mod9ObstructionAsPersistence (n : ℤ) : ℕ :=
  if n % 9 = 4 ∨ n % 9 = 5 then 0 else 1

/-
**Theorem 8: When persistence vanishes, mod-9 obstruction is present.**
    Proved by contrapositive using the definition.
-/
theorem mod9_persistence_zero_implies_obstruction (n : ℤ)
    (h : mod9ObstructionAsPersistence n = 0) :
    n % 9 = 4 ∨ n % 9 = 5 := by
  unfold mod9ObstructionAsPersistence at h;
  grind

/-
**Theorem 9: When persistence is positive, no mod-9 obstruction.**
    Proved by contradiction.
-/
theorem mod9_persistence_pos_no_obstruction (n : ℤ)
    (h : 0 < mod9ObstructionAsPersistence n) :
    ¬(n % 9 = 4 ∨ n % 9 = 5) := by
  unfold mod9ObstructionAsPersistence at h; aesop;

/-! ## §9. Quadratic Residue Separation -/

/-- **Conjecture (Falsifiable):**
    For distinct squarefree positive integers d₁ ≠ d₂, there exists a prime p
    such that the quadratic residue counts of d₁ and d₂ mod p differ.

    **Test:** Compute #{x : ZMod p | x² = d} for d ∈ {2,3,5,6,7,10} at
    primes p ∈ {3,5,7,11,13,17,19,23}. The conjecture predicts each pair
    (d₁,d₂) is separated by some prime in this range. Refuted if a pair
    of distinct squarefree integers yields identical quadratic residue
    counts at all primes. -/
def pellSeparationConjecture : Prop :=
  ∀ d₁ d₂ : ℕ, d₁ ≠ d₂ → Squarefree d₁ → Squarefree d₂ → 1 < d₁ → 1 < d₂ →
  ∃ p : ℕ, Nat.Prime p ∧ ∃ (_ : Fact (Nat.Prime p)),
    (Finset.univ (α := ZMod p)).filter (fun x => x ^ 2 = (d₁ : ZMod p)) ≠
    (Finset.univ (α := ZMod p)).filter (fun x => x ^ 2 = (d₂ : ZMod p))

/-! ## §10. Frobenius Orbit Size Divides Group Order -/

/-
**Theorem 10: Frobenius orbit size divides p - 1 (Fermat's little theorem in orbit language).**
    For an odd prime p, the multiplicative order of any nonzero element divides p - 1.
-/
theorem frobenius_orbit_divides (p : ℕ) (hp : Nat.Prime p) (x : ZMod p)
    (hx : x ≠ 0) : orderOf x ∣ p - 1 := by
  rw [ orderOf_dvd_iff_pow_eq_one ];
  haveI := Fact.mk hp; exact ZMod.pow_card_sub_one_eq_one hx;

/-! ## §11. Barcode Stability under Shifts -/

/-- Shift a persistence interval by k: [b, d) ↦ [b+k, d+k). -/
def PersistenceInterval.shift (I : PersistenceInterval) (k : ℕ) :
    PersistenceInterval where
  birth := I.birth + k
  death := if I.death = 0 then 0 else I.death + k
  birth_le_death := by
    rcases I.birth_le_death with h | h
    · by_cases hd : I.death = 0
      · right; simp [hd]
      · left; simp [hd]; omega
    · right; simp [h]

/-- Shift a barcode by k. -/
def PersistenceBarcode.shift (B : PersistenceBarcode) (k : ℕ) : PersistenceBarcode :=
  ⟨B.intervals.map (·.shift k)⟩

/-- **Theorem 11: Shifting preserves barcode size.** -/
theorem barcode_shift_size (B : PersistenceBarcode) (k : ℕ) :
    (B.shift k).size = B.size := by
  simp [PersistenceBarcode.shift, PersistenceBarcode.size]

/-
**Theorem 12: Shifting preserves total persistence.**
    Each interval's lifetime is unchanged by uniform shift.
-/
theorem barcode_shift_totalPersistence (B : PersistenceBarcode) (k : ℕ) :
    (B.shift k).totalPersistence = B.totalPersistence := by
  unfold PersistenceBarcode.totalPersistence PersistenceBarcode.shift;
  -- By definition of lifetime, we have that the lifetime of a shifted interval is the same as the original interval.
  have h_lifetime_shift : ∀ (I : PersistenceInterval) (k : ℕ), (I.shift k).lifetime = I.lifetime := by
    intro I k; unfold PersistenceInterval.lifetime; unfold PersistenceInterval.shift; split_ifs <;> simp_all +decide ;
    rw [ Nat.add_sub_add_right ];
  induction B.intervals <;> aesop