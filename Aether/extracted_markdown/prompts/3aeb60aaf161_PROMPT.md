## Research Task: Composite-index Fibonacci primitive divisors via entry-point divisibility and gcd control

Research Mode: SORRY_FILL

Fill the remaining `sorry`s in the Carmichael/Fibonacci development by making the entry-point machinery the central reusable interface between “a prime divides `Fib n`” and “that prime first appears at an index dividing `n`”. The goal is to eliminate the current gap in the composite-index case and make the large-`n` Carmichael theorem go through uniformly in the Shared and Speculative developments.

### Files / likely targets
Focus first on the `sorry`s in the Carmichael proof files, especially the bridge lemmas and the composite-index primitive-divisor step. The key missing statements are expected to live in or near:
- `Shared/CarmichaelProof.lean`
- mirrored speculative Carmichael files with the same proof skeleton
- any auxiliary Fibonacci divisibility file where `fibEntry`, `entry_point_divides`, `gcd(F_m,F_n)=F_gcd(m,n)`, or “primitive part” are already introduced

Do not change statements; instead, prove the exact existing lemmas. If the codebase contains duplicated statements under slightly different names, prove the most structural version first and then use it to discharge the mirrored sorries with short wrappers.

---

## Precise theorem targets

The central reusable bridge should have one of the following exact shapes, depending on the names already present in the file:

```lean
theorem fibEntry_dvd_of_prime_dvd_fib
    (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
    (hdiv : p ∣ fib n) :
    fibEntry p ∣ n
```

or, if already named in the file:

```lean
theorem fibEntryPt_dvd_of_fib_dvd
    (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n)
    (hdiv : p ∣ fib n) :
    fibEntry p ∣ n
```

Very often this is just a wrapper around an existing theorem such as:

```lean
entry_point_divides (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n) (hpn : p ∣ fib n) :
  fibEntry p ∣ n
```

If that theorem already exists, the missing proof should simply normalize assumptions and apply it.

A useful iff-form, if present as a `sorry`, should be proved in the prime case:

```lean
theorem fib_dvd_iff_entry_dvd
    (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n) :
    p ∣ fib n ↔ fibEntry p ∣ n
```

For this, the forward implication is the bridge theorem above; the reverse implication should use the defining property of `fibEntry p` as an index where `p ∣ fib (fibEntry p)` together with Fibonacci divisibility under divisibility of indices:

```lean
theorem fib_dvd_of_dvd_indices
    {m n : ℕ} (h : m ∣ n) :
    fib m ∣ fib n
```

or whatever exact theorem name is already in the library.

A proper-divisor exclusion lemma should then have a shape close to:

```lean
theorem prime_not_earlier_of_entry_eq
    {p n d : ℕ}
    (hp : Nat.Prime p)
    (hn : 0 < n)
    (hpn : p ∣ fib n)
    (hentry : fibEntry p = n)
    (hdn : d ∣ n)
    (hdlt : d < n) :
    ¬ p ∣ fib d
```

A slightly weaker but often easier-to-use version is:

```lean
theorem proper_divisor_exclusion
    {p n d : ℕ}
    (hp : Nat.Prime p)
    (hdn : d ∣ n)
    (hdlt : d < n)
    (hpd : p ∣ fib d) :
    fibEntry p ∣ d
```

followed by contradiction from `fibEntry p = n` and `d < n`.

If the file defines a predicate expressing primitivity, the target theorem should look like one of:

```lean
theorem primitive_of_entryPt_eq
    {p n : ℕ}
    (hp : Nat.Prime p)
    (hn : 0 < n)
    (hpn : p ∣ fib n)
    (hentry : fibEntry p = n) :
    IsPrimitivePrimeDivisor p n
```

or explicitly:

```lean
theorem primitive_of_entryPt_eq
    {p n : ℕ}
    (hp : Nat.Prime p)
    (hn : 0 < n)
    (hpn : p ∣ fib n)
    (hentry : fibEntry p = n) :
    (p ∣ fib n) ∧ ∀ m, 0 < m → m < n → ¬ p ∣ fib m
```

Finally, the composite-index existence theorem should package the primitive-part argument. Expect something close to:

```lean
theorem fib_composite_has_primitive
    {n : ℕ}
    (hn : 0 < n)
    (hcomp : Nat.Composite n)
    (hexc : n ∉ exceptionalSet) :
    ∃ p, Nat.Prime p ∧ IsPrimitivePrimeDivisor p n
```

or a variant with hypotheses saying the primitive part of `fib n` is `> 1`, from which one extracts a prime factor:

```lean
theorem fib_composite_has_primitive
    {n : ℕ}
    (hn : 0 < n)
    (hprimpart : 1 < primitivePart n) :
    ∃ p, Nat.Prime p ∧ p ∣ fib n ∧ ∀ m, 0 < m → m < n → ¬ p ∣ fib m
```

If the file already proves existence of a prime dividing the primitive part, the missing step is almost certainly to show that such a prime cannot divide any earlier `fib d`, using entry-point divisibility and the gcd/divisor machinery.

---

## Proof strategy

### 1. Prove the entry-point divisibility bridge by direct reuse of the existing entry-point theorem
If the code already contains:

```lean
entry_point_divides (p n : ℕ) (hp : Nat.Prime p) (hn : 0 < n) (hpn : p ∣ fib n) :
  fibEntry p ∣ n
```

then the missing theorem should be proved by exact application. Typical proof pattern:

```lean
exact entry_point_divides p n hp hn hdiv
```

or

```lean
simpa using entry_point_divides p n hp hn hdiv
```

If there is coercion noise between `F` and `fib`, or between a local notation and `Nat.fib`, resolve it with `simpa [notation_name]`.

This bridge is the key abstraction: it converts every divisibility occurrence `p ∣ fib k` into an index divisibility statement `fibEntry p ∣ k`, which is exactly what is needed to control earlier divisors.

### 2. Derive the “no earlier occurrence” lemma from `fibEntry p = n`
To prove

```lean
¬ p ∣ fib d
```

for `d < n`, assume `hpd : p ∣ fib d`. Then by the bridge theorem,

```lean
hdivd : fibEntry p ∣ d
```

and after rewriting with `hentry : fibEntry p = n`, obtain `n ∣ d`. Since also `d < n`, this is impossible.

Concrete Lean steps:
1. `have hz : fibEntry p ∣ d := fibEntry_dvd_of_prime_dvd_fib p d hp hdpos hpd`
2. `rw [hentry] at hz`
3. Obtain `d = 0 ∨ 0 < d` if needed by cases.
4. From `n ∣ d` and `d < n`, derive contradiction using:
   - `Nat.le_of_dvd`
   - `Nat.pos_of_ne_zero`
   - or `have : n ≤ d := Nat.le_of_dvd ... hz`
   - then `exact (not_le_of_gt hdlt) this`

For proper divisors `d ∣ n` with `d < n`, positivity is often needed to invoke the bridge theorem. Get it from:
- `Nat.pos_of_lt hdlt` if `0 < n` and `d < n` is not enough, or
- split off the `d = 0` case separately, where `p ∣ fib 0` may need special handling (`fib 0 = 0`), depending on the exact primitive-divisor definition. Usually primitive-divisor predicates quantify over `0 < m < n`, so the `m = 0` case is irrelevant.

### 3. Use gcd control when the file phrases “earlier occurrence” via common divisors of `fib d` and `fib n`
Some sorries may be written in a style that first uses the identity

```lean
Nat.gcd (fib m) (fib n) = fib (Nat.gcd m n)
```

or an equivalent divisibility corollary. In that situation, the key transfer is:

If `p ∣ fib d` and `p ∣ fib n`, then `p ∣ fib (Nat.gcd d n)`.

When `d ∣ n`, `Nat.gcd d n = d`, so this gives no contradiction by itself; the real contradiction still comes from the entry point:
- `p ∣ fib d` implies `fibEntry p ∣ d`
- `p ∣ fib n` implies `fibEntry p ∣ n`
- if additionally `fibEntry p = n`, then `n ∣ d`, impossible for `d < n`

So if a current proof attempt is stuck over the gcd identity, do not overuse it. Use gcd only to align with the file’s primitive-part or proper-divisor bookkeeping; the decisive step is the entry-point minimality/divisibility argument.

### 4. Extract a prime divisor from the primitive part and show it is primitive
For the existence theorem, the structure should be:

1. Obtain a prime `p` dividing the primitive part:
   ```lean
   rcases Nat.exists_prime_and_dvd hgt with ⟨p, hp, hppart⟩
   ```
   where `hgt : 1 < primitivePart n`.
2. Convert `p ∣ primitivePart n` into `p ∣ fib n`.
3. Use the definition of primitive part to show `p` does not divide the product over proper divisors, or directly any `fib d` for proper `d ∣ n`.
4. If the primitive-part definition only gives “not dividing the product”, use primality plus `Nat.Prime.dvd_of_dvd_pow`-style or `Nat.Prime.dvd_of_dvd_prod` lemmas on the proper-divisor finset/product to get pointwise exclusion.
5. Conclude `IsPrimitivePrimeDivisor p n` by bundling:
   - `hp`
   - `p ∣ fib n`
   - `∀ m, 0 < m → m < n → ¬ p ∣ fib m`

If the primitive part was defined by dividing out gcds or a product of earlier factors, then the key local lemma is often:
```lean
hp.not_dvd_one
```
applied after showing that if `p` divided some earlier `fib d`, it would divide the denominator/product removed from `fib n`, contradicting `p ∣ primitivePart n`.

### 5. Unify Shared and Speculative proofs by proving the strongest helper lemma first
There is likely duplicated proof skeleton around:
- `bridge_lemma`
- `fibEntryPt_dvd_of_fib_dvd`
- `primitive_of_entryPt_eq`
- `fib_composite_has_primitive`
- final `fib_carmichael_large'`

Prove the most general helper in one place:
```lean
theorem prime_not_earlier_of_entry_eq ...
```
Then the downstream sorries should collapse to short proofs:
```lean
refine ⟨hp, hpn, ?_⟩
intro m hm0 hmn
exact prime_not_earlier_of_entry_eq hp hn hpn hentry ?hdv hmn
```
or by applying the helper with `hdn := dvd_trans ...`.

This avoids reproving the same divisibility contradiction in multiple files.

---

## Lean-specific proof hints

- For contradiction from `n ∣ d` and `d < n`, the cleanest pattern is usually:
  ```lean
  have hnd_le : n ≤ d := Nat.le_of_dvd (lt_trans Nat.zero_lt_one? ? ) hnd
  exact (not_le_of_gt hdlt) hnd_le
  ```
  but you need positivity of `d`. Often you can get it from `hdlt` and `hn`, or from a separate hypothesis `0 < d`.

- If rewriting `fibEntry p = n` in a divisibility hypothesis is awkward, use:
  ```lean
  have h' : n ∣ d := by simpa [hentry] using hz
  ```

- For proper divisors from a finset of divisors:
  ```lean
  have hdn : d ∣ n := by
    exact Finset.mem_divisors.mp hd_mem |>.1
  ```
  or the corresponding theorem already used nearby in the file.

- If primitive-divisor predicates quantify over all earlier indices rather than just divisors of `n`, the argument is even easier: from `p ∣ fib m` with `0 < m < n`, bridge gives `fibEntry p ∣ m`; rewriting by `fibEntry p = n` yields `n ∣ m`, contradiction.

- If you need positivity of `fibEntry p`, look for a lemma already present:
  ```lean
  fibEntry_pos (hp : Nat.Prime p) : 0 < fibEntry p
  ```
  or derive it from the minimality construction via `Nat.find_pos`. This may be necessary in proofs of `Nat.le_of_dvd`.

- If the entry point is defined by `Nat.find`, the minimality lemma likely has one of the forms:
  ```lean
  Nat.find_spec ...
  Nat.find_min' ...
  ```
  Use these only if the direct theorem `entry_point_divides` is unavailable. In that case, the proof of the bridge should go:
  1. `p ∣ fib (fibEntry p)` by `Nat.find_spec`
  2. Use the known theorem “if `p` divides two Fibonacci numbers, then it divides the Fibonacci at the gcd of the indices”
  3. By minimality of `fibEntry p`, deduce `fibEntry p ≤ gcd (fibEntry p) n`
  4. Hence `fibEntry p ∣ n`
  
  But prefer the preexisting theorem if it exists.

---

## Why this matters

This is the missing structural step in the Carmichael formalization: once “prime divisor of `fib n` ⇒ entry point divides `n`” is integrated cleanly with the gcd/divisor infrastructure, the composite-index primitive-divisor theorem becomes routine rather than ad hoc. That in turn is exactly what is needed to finish the large-index Carmichael result and remove the current duplication between Shared and Speculative proofs.

More importantly, this lemma package creates a reusable arithmetic interface for Fibonacci divisibility in Lean:
- occurrence of a prime in Fibonacci values is controlled by an index invariant (`fibEntry`)
- primitive-divisor arguments reduce to simple order/divisibility contradictions
- future computational extensions only need to verify the finite exceptional set, while the formal proof handles all larger composite indices uniformly

So the highest-value outcome is not just filling one `sorry`, but isolating the reusable chain:

```lean
p ∣ fib n
→ fibEntry p ∣ n
→ if fibEntry p = n then p is primitive at n
→ any prime divisor of the primitive part gives a primitive prime divisor of fib n
```

Once this chain is formalized cleanly, the final `fib_carmichael_large'` theorem should become a short assembly argument rather than a bespoke composite-case proof.

### Catalog Reference Files
            No specific files referenced. Use Mathlib and general knowledge.


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
