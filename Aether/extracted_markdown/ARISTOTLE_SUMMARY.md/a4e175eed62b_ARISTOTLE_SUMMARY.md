# Summary of changes for run bfb3f09a-e96d-4419-9a43-89d6d5ab0dca
## Berggren Dynamics as Arithmetic Group Action — Complete Delivery

### Formally Verified Mathematics (Lean 4)

**File:** `Pythagorean/BerggrenGroupAction.lean` (also copied to `Catalog/Pythagorean/`)
- **330 lines, zero sorry statements**, builds cleanly
- Only standard axioms used: `propext`, `Classical.choice`, `Quot.sound`

**Definitions introduced:**
- `Triple`, `BerggrenGen` (A/B/C), `BerggrenWord` — the word-action framework
- `applyGen`, `actsOnTriple` — recursive semigroup action on integer triples
- `IsNullLorentz`, `IsPositiveTriple`, `IsPrimitiveTriple`, `IsPrimitiveNullPositive` — predicates
- `BerggrenReachable` — reachability groupoid relation
- `ModTriple`, `applyGenMod`, `actsOnModTriple` — finite-state modular reduction
- `enumerateByDepth`, `enumerateUpTo` — certified enumeration algorithm

**Theorems proved (all sorry-free):**

1. **Semigroup action preserving the null cone:**
   - `applyGen_preserves_null` — each generator preserves a²+b²=c²
   - `berggren_word_preserves_pythagorean` — every word preserves it (induction on word)
   - `actsOnTriple_append` — action respects word concatenation
   - `berggren_reachable_trans` — transitivity of reachability

2. **Modular invariant propagation:**
   - `applyGenMod_preserves_null` — generators preserve mod-m null cone (via `linear_combination`)
   - `berggren_word_preserves_pythagorean_mod` — words preserve mod-m relation
   - `root_descendants_on_modular_nullcone` — all (3,4,5) descendants on modular null cone
   - `berggren_mod_state_closed` — finite-state reduction theorem

3. **Strict hypotenuse growth and acyclicity:**
   - `applyGen_preserves_positive` — generators preserve positivity (using nlinarith with c > a, c > b)
   - `berggren_gen_increases_hypotenuse` — each generator strictly increases hypotenuse
   - `berggren_word_preserves_positive` — words preserve positivity
   - `berggren_nonempty_word_strictly_increases_hypotenuse` — nonempty words strictly grow hypotenuse
   - `berggren_no_nontrivial_fixed_point` — no nontrivial word fixes a positive Pythagorean triple

4. **Certified enumeration:**
   - `enumerateUpTo_sound` — every output satisfies a²+b²=c² and respects the bound

### Deliverables

- **`ARTICLE.md`** — Popular-science article (~2500 words) connecting Pythagorean triples to light cones, finite automata, and prime statistics
- **`RESEARCH_PAPER.md`** — Full research paper with abstract, theorems, proof sketches, algorithms, computational experiments, and references
- **`FUTURE_DIRECTIONS.md`** — 5 falsifiable conjectures: modular equidistribution, prime branch bias, strong connectivity, primitivity preservation, and Lyapunov exponent universality
- **`demo.py`** — Complete interactive demonstration: tree generation, hypotenuse growth, modular orbit graphs, prime mod-4 verification, and all three conjecture tests
- **`algorithms.py`** — BFS enumeration, sorted enumeration, modular orbit graph with SCC analysis, prime density estimation, growth statistics
- **`applications.py`** — Engineering triangle search, pseudorandom generation, rational angle generation, modular fingerprinting
- **`PACKAGE.json`** — Complete JSON data package with all content properly escaped