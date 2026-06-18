## Research Task: Entry-point divisibility equivalence for Fibonacci numbers enabling the composite-index primitive divisor closure

Research Mode: SORRY_FILL

Fill the existing `sorry` placeholders in the Fibonacci/Carmichael bridge layer, without changing theorem statements. The missing content should establish the exact equivalence between divisibility into Fibonacci values and divisibility of the corresponding entry point into the index, and then package the consequences in the divisibility form used downstream by the Carmichael composite-index arguments.

### Files and theorem targets
The relevant sorries are expected to live in one or more of:

- `Shared/FibonacciEntryPoint.lean`
- `Shared/CarmichaelProof.lean`
- possibly bridge consumers in
  - `Speculative/AutoResearch/CarmichaelComposite.lean`
  - `Speculative/AutoResearch/FibPrimitive.lean`

If theorem names differ slightly, use the surrounding context as the guide. The key missing lemmas should be of the following shape, or definitionally equivalent variants already present in the files:

```lean
theorem fib_dvd_of_dvd {d n : ℕ} (h : d ∣ n) : Nat.fib d ∣ Nat.fib n
```

```lean
theorem fibEntry_dvd_of_dvd_fib {n m : ℕ} (hn : 0 < n) :
    n ∣ Nat.fib m → fibEntry n ∣ m
```

```lean
theorem dvd_fib_iff_fibEntry_dvd {n m : ℕ} (hn : 0 < n) :
    n ∣ Nat.fib m ↔ fibEntry n ∣ m
```

and the gcd/divisibility bridge in the form actually needed by the Carmichael files, for example:

```lean
theorem fib_gcd_dvd_left (a b : ℕ) : Nat.fib (Nat.gcd a b) ∣ Nat.fib a
theorem fib_gcd_dvd_right (a b : ℕ) : Nat.fib (Nat.gcd a b) ∣ Nat.fib b
```

or, if the library already has the strong divisibility theorem available:

```lean
theorem fib_gcd :
    Nat.fib (Nat.gcd a b) = Nat.gcd (Nat.fib a) (Nat.fib b)
```

together with the bridge consequence actually used downstream:

```lean
theorem fib_dvd_gcd_of_dvd {a b c : ℕ}
    (ha : c ∣ Nat.fib a) (hb : c ∣ Nat.fib b) : c ∣ Nat.fib (Nat.gcd a b)
```

If the local API uses `Fibonacci.fib`, `Nat.fib`, `entryPoint`, `fibEntry`, or `fibEntryPt`, preserve the existing names exactly and adapt the proof accordingly.

### Precise mathematical goal
For every positive integer `n`, the entry point `fibEntry n` is the least positive index where `n ∣ fib k`. The bridge theorem to complete is:

```lean
∀ {n m : ℕ}, 0 < n → (n ∣ Nat.fib m ↔ fibEntry n ∣ m)
```

This should then yield the index-level consequence used in the composite-index primitive divisor proof:

```lean
∀ {n m : ℕ}, 0 < n → Nat.fib n ∣ Nat.fib m → fibEntry (Nat.fib n) ∣ m
```

and, in contexts where the development has already identified `fibEntry (Nat.fib n)` with `n` or at least shown `fibEntry (Nat.fib n) ∣ n`, it should feed the proper-divisor elimination argument in the Carmichael pipeline.

### Proof strategy hints
1. **First isolate the easy divisibility-along-multiples lemma.**  
   From `k ∣ m`, prove `Nat.fib k ∣ Nat.fib m` using the standard Fibonacci divisibility theorem already in Mathlib or in the local file. Usually this is the simplest bridge and is often enough to discharge several downstream sorries immediately. If a theorem of the form
   ```lean
   Nat.fib_dvd_fib : Nat.fib m ∣ Nat.fib n ↔ m ∣ n
   ```
   already exists, use it directly. Otherwise there is often at least the forward direction available:
   ```lean
   d ∣ n → Nat.fib d ∣ Nat.fib n
   ```

2. **Use the minimality property built into the entry-point definition/API.**  
   The difficult implication in
   ```lean
   n ∣ Nat.fib m → fibEntry n ∣ m
   ```
   should not be reproved from scratch by periodicity. The surrounding file likely already contains:
   - existence: `n ∣ Nat.fib (fibEntry n)`
   - positivity: `0 < fibEntry n` when `0 < n`
   - minimality: if `0 < k` and `n ∣ Nat.fib k`, then `fibEntry n ≤ k`

   The bridge proof should proceed by applying a strong-divisibility or gcd lemma to `fib (fibEntry n)` and `fib m`. Since both are divisible by `n`, one gets `n ∣ fib (gcd (fibEntry n) m)`. By minimality of `fibEntry n`, this forces
   ```lean
   fibEntry n ≤ Nat.gcd (fibEntry n) m
   ```
   and therefore equality with the gcd, hence `fibEntry n ∣ m`.

3. **Exploit the strong divisibility law in gcd form.**  
   The key arithmetic identity is
   ```lean
   Nat.gcd (Nat.fib a) (Nat.fib b) = Nat.fib (Nat.gcd a b)
   ```
   or its divisibility corollary. If the exact equality is already present, use it to transport common divisibility of `Nat.fib a` and `Nat.fib b` down to `Nat.fib (gcd a b)`. If only divisibility lemmas are present, derive the needed statement via `Nat.dvd_gcd` / `Nat.gcd_dvd_left` / `Nat.gcd_dvd_right`. This is the cleanest route to the forward implication of the entry-point equivalence.

4. **For the reverse implication, reduce to the defining divisibility at the entry point plus divisibility along multiples.**  
   Assuming `fibEntry n ∣ m`, write `m = fibEntry n * t`, use the theorem that `n ∣ Nat.fib (fibEntry n)`, and then apply the “fib of divisor divides fib of multiple” lemma to conclude
   ```lean
   n ∣ Nat.fib m.
   ```
   In Lean, this is usually a two-line proof after obtaining
   ```lean
   Nat.fib (fibEntry n) ∣ Nat.fib m
   ```
   from the divisibility of indices.

5. **Be careful about the `n = 0` edge case.**  
   The equivalence is false or degenerate without a positivity assumption, so every theorem of the form
   ```lean
   n ∣ Nat.fib m ↔ fibEntry n ∣ m
   ```
   should explicitly assume `0 < n` if the file’s theorem statement does. Many proof failures in this area come from trying to invoke minimality lemmas whose hypotheses require positivity. Use `Nat.pos_of_ne_zero` and `omega`/`linarith`-style arithmetic only if already imported; otherwise prefer `Nat.succ_le_of_lt`, `Nat.gcd_le_left`, and `Nat.le_antisymm`.

### Lean implementation sketch
A robust proof of the forward bridge often has the following structure:

```lean
theorem fibEntry_dvd_of_dvd_fib {n m : ℕ} (hn : 0 < n)
    (hm : n ∣ Nat.fib m) : fibEntry n ∣ m := by
  have hzpos : 0 < fibEntry n := fibEntry_pos hn
  have hzfib : n ∣ Nat.fib (fibEntry n) := fibEntry_dvd_fib hn
  have hg : n ∣ Nat.fib (Nat.gcd (fibEntry n) m) := by
    -- derive from common divisibility of fib (fibEntry n) and fib m
    -- via fib_gcd or fib_dvd_gcd_of_dvd
  have hmin := fibEntry_min hn (Nat.gcd_pos_of_pos_left m hzpos) hg
  have hle : fibEntry n ≤ Nat.gcd (fibEntry n) m := hmin
  have hge : Nat.gcd (fibEntry n) m ≤ fibEntry n := Nat.gcd_le_left _ _
  have heq : Nat.gcd (fibEntry n) m = fibEntry n := Nat.le_antisymm hge hle
  exact Nat.dvd_of_gcd_eq_left heq
```

Depending on the local theorem names, `fibEntry_min` may instead say that `fibEntry n` is the least positive `k` satisfying `n ∣ fib k`, in which case use `Nat.find_min'` or the local wrapper around it.

The reverse implication should then be:

```lean
theorem dvd_fib_of_fibEntry_dvd {n m : ℕ} (hn : 0 < n)
    (h : fibEntry n ∣ m) : n ∣ Nat.fib m := by
  have hzfib : n ∣ Nat.fib (fibEntry n) := fibEntry_dvd_fib hn
  have hfib : Nat.fib (fibEntry n) ∣ Nat.fib m := fib_dvd_of_dvd h
  exact dvd_trans hzfib hfib
```

and combine both directions with `Iff.intro`.

If a theorem already exists in Mathlib with essentially the final statement, prefer a one-line wrapper rather than reproving it. The point is to connect the local `fibEntry` API to the divisibility theorems already available.

### Downstream bridge lemmas to derive immediately
Once the equivalence is in place, the sorries in the Carmichael files should collapse to short wrappers such as:

```lean
theorem bridge_lemma {n m : ℕ} (hn : 0 < Nat.fib n)
    (h : Nat.fib n ∣ Nat.fib m) : fibEntry (Nat.fib n) ∣ m :=
  fibEntry_dvd_of_dvd_fib hn h
```

and

```lean
theorem fib_dvd_of_index_dvd {d n : ℕ} (h : d ∣ n) : Nat.fib d ∣ Nat.fib n :=
  fib_dvd_of_dvd h
```

Also derive whatever proper-divisor form the composite proof asks for, e.g.

```lean
theorem fib_of_proper_dvd_dvd {d n : ℕ} (hd : d ∣ n) : Nat.fib d ∣ Nat.fib n
```

possibly with side conditions `d < n`, `0 < d`, or `n ≠ 0`.

### Why this matters
This is the exact arithmetic bridge the composite-index primitive divisor argument needs. The remaining Carmichael gap is not about finding new primes; it is about controlling which indices can account for already-known divisors of `fib m`. The theorem
```lean
n ∣ Nat.fib m ↔ fibEntry n ∣ m
```
converts a divisibility statement in the Fibonacci sequence into a clean divisibility statement on indices. That is the mechanism required to show that any prime dividing both a proper-divisor Fibonacci term and the full composite-index term must already come from an index divisor, so a genuinely new prime can be forced at the top index. Completing these sorries therefore upgrades the current partial composite-index formalization into the reusable shared engine for the full Carmichael-style primitive divisor closure.

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
