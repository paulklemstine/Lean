# When Your Spreadsheet Becomes Geometry: Databases as Sheaves

## The everyday miracle of merging two tables

Every data analyst has done it a thousand times. You have one spreadsheet of
customers and their email addresses. A colleague hands you another spreadsheet
of customers and their phone numbers. You want a single table with names,
emails, and phone numbers. So you *merge*.

Most of the time the merge just works. But sometimes it doesn't: the same
customer appears in both tables with two different email addresses, and now your
software throws up its hands. Which one is right? The merge has hit a
**contradiction**.

This tiny, mundane drama — *can I combine these two tables into one consistent
table?* — turns out to be a deep mathematical question. And the branch of
mathematics that answers it most precisely is one that was invented to study
something completely different: the geometry of how *local* information glues
into *global* information. That subject is called **sheaf theory**, and its
central insight is that consistency is a geometric property.

This article tells the story of a precise theorem: **databases form a sheaf.**
Not "databases are *like* a sheaf" as a loose analogy, but a genuine theorem
with the full strength of a mathematical proof behind it. Once you see it, the
question "can these tables be merged?" stops being a software heuristic and
becomes a statement about geometry — and the answer comes with a guarantee of
*uniqueness*.

## What a sheaf actually is (without the jargon)

Imagine a map of a country, and suppose every town keeps its own local weather
log. Each log records the temperature only for that town and its immediate
surroundings. Now ask: can all these local logs be stitched together into one
coherent national weather map?

There's an obvious requirement. Wherever two towns' regions overlap, their logs
had better *agree* on the temperature in the shared area. If town A says it's
20°C in the valley between them and town B says it's 25°C in that same valley,
no national map can satisfy both. But if every pair of overlapping logs agrees
on the overlap, intuition says they should fit together into one big map — and
in exactly one way.

A **sheaf** is the mathematical structure that makes this intuition into a
theorem. It has two ingredients:

- **Restriction.** From data on a big region you can always *forget* down to
  data on a smaller region. (From the national map you can read off any town's
  local weather.) This is just "looking at a sub-part."
- **The sheaf condition (gluing + separation).** If you have local data on a
  cover — a collection of regions whose union is the whole space — and the local
  pieces *agree on overlaps*, then there is **one and only one** global piece of
  data that restricts back to each of them.

"Gluing" says a consistent family *can* be assembled. "Separation" says the
assembled object is *unique* — two global objects that look the same locally
everywhere must actually be equal. Together they are the beating heart of sheaf
theory.

The claim of this work is that a database, with all its rows and columns and
its inevitable missing entries, is *exactly* such a structure.

## The dictionary: from spreadsheets to sheaves

Here is the translation that powers everything.

Fix a space of **keys** $K$. Think of a key as "the address of one cell" — for
instance, the pair (customer #4096, field "email"). Fix a type $\mathrm{Val}$ of
possible **values** — strings, numbers, whatever your cells hold.

A **database over a set of keys $U \subseteq K$** is then nothing more than a
rule that assigns a value to every key in $U$. Formally it is a function

$$ s : U \to \mathrm{Val}. $$

We call such a thing a *record* over $U$. A complete database is a record over
*all* the keys it needs; a database "with missing entries" is a record over a
*partial* set of keys — the cells that happen to be filled in. The missing cells
are simply the keys not in $U$.

**Restriction** is then trivial: if $W \subseteq U$ is a smaller set of keys, a
record $s$ on $U$ restricts to a record on $W$ by just reading off the values at
the keys in $W$:

$$ (\mathrm{restrict}\, s)(x) = s(x), \qquad x \in W. $$

Two bookkeeping facts make this a genuine *presheaf* — the raw scaffolding a
sheaf is built on. First, restricting to the same set you started with changes
nothing:

$$ \mathrm{restrict}_{U \subseteq U}\, s = s. $$

Second, restricting in two steps (from $U$ down to $W$, then down to $X$) is the
same as restricting in one step straight to $X$:

$$ \mathrm{restrict}_{X \subseteq W}\big(\mathrm{restrict}_{W \subseteq U}\, s\big)
   = \mathrm{restrict}_{X \subseteq U}\, s. $$

These look almost too obvious to state. But they are the formal "presheaf laws,"
and they are the first two theorems proved in this work. Stating the obvious
precisely is exactly what lets us prove the non-obvious rigorously.

## Consistency, made exact

Now suppose we have a whole family of partial databases. We index them by some
label $i$, so database number $i$ is a record $r_i$ defined on a key set $S_i$.
These might be the customer table, the orders table, the shipping table — each
covering its own slice of the key space, with plenty of overlap.

When can they be merged? The everyday answer is "when they don't contradict each
other." The exact answer is a single clean condition. The family is
**overlap-consistent** when, for any two databases $i$ and $j$ and any key $x$
that lies in *both* $S_i$ and $S_j$, the two databases assign the same value:

$$ r_i(x) = r_j(x) \quad \text{whenever } x \in S_i \cap S_j. $$

That's it. No averaging, no priorities, no tie-breaking — just literal
agreement on shared cells. This is the database administrator's intuition
("the tables agree on the columns they share") promoted to a mathematical
definition.

## The headline theorems

With the dictionary in place, the sheaf axioms become statements about merging
data — and they are *proved*, not assumed.

**Separation (a global database is pinned down by its parts).** Suppose two
complete databases $g$ and $g'$ live over the union $\bigcup_i S_i$ of a cover,
and suppose they look *identical* when restricted to every piece $S_i$ of the
cover. Then they are the same database:

$$ \big(\forall i,\ \mathrm{restrict}_{S_i}\, g = \mathrm{restrict}_{S_i}\, g'\big)
   \implies g = g'. $$

In plain language: there is no "hidden" information in a database beyond what its
sub-tables reveal. If every view agrees, the underlying data is unique. This is
the theorem `glue_eq_of_locally_eq`.

**Gluing (consistent parts assemble into a whole).** This is the centerpiece,
`exists_unique_glue`. Take any family of partial databases $r_i$ over a cover
$\{S_i\}$, and suppose the family is overlap-consistent. Then there exists a
**unique** global database $g$ over the union $\bigcup_i S_i$ whose restriction to
each $S_i$ is exactly the local database $r_i$:

$$ \exists!\, g,\quad \forall i,\ \mathrm{restrict}_{S_i}\, g = r_i. $$

The merge always succeeds, *and the result is one of a kind*. There is no
ambiguity about which merged table you get: agreement on overlaps forces a single
answer. The proof is constructive — to find the value of $g$ at a key $x$, locate
any database $S_i$ that contains $x$ and read off $r_i(x)$; overlap-consistency
guarantees that the choice of $i$ does not matter.

These two combine into a perfect "if and only if," the theorem
`exists_glue_iff_consistent`, which is the actual decision procedure a database
engine implements:

$$ \big(\text{the tables can be merged}\big) \iff \big(\text{they are
   overlap-consistent}\big). $$

The everyday question — *can I merge?* — is provably **equivalent** to the
cheap-to-check question — *do they agree on shared keys?* You never have to
search for a merge to know whether one exists; you only have to check pairwise
agreement.

Finally, the most common case of all, merging just two tables, gets its own
sharp statement, `exists_unique_merge_two`. If two databases $r_0$ on keys $S_0$
and $r_1$ on keys $S_1$ agree on the shared keys $S_0 \cap S_1$, then there is a
*unique* merged database on $S_0 \cup S_1$ restricting to each. This is the
mathematical content of the SQL `JOIN`/`UNION` you run every day.

## The second picture: schemas as networks

There is a second, complementary way databases become sheaves, and it connects
data integration to a field called **cellular sheaf cohomology** — the algebra
of how local agreements obstruct (or permit) global consistency.

Picture your data sources as **nodes** in a network, and draw an **edge**
between two sources whenever they are supposed to agree about something. This is
a *schema graph* $G$. A **consistent integration** of the whole system is an
assignment of data to every node such that every edge's agreement constraint is
satisfied. These consistent integrations form a tidy algebraic object — a
submodule called `globalSections`.

When the agreement constraint is simply "equal values," the consistent
integrations are precisely the **zeroth cohomology** $H^0(G)$ of the graph — the
space of functions that are constant along edges. And cohomology answers a
beautiful structural question with a one-line theorem:

> **Rigidity over a connected schema.** If the schema graph is *connected* — every
> source is linked, directly or through a chain, to every other — then a
> consistent integration is completely determined by its value at any *single*
> node.

This is `globalSections_eval_injective_of_connected`, resting on the cohomology
fact `H0_eq_const_of_connected` that over a connected graph the only globally
consistent assignments are the constant ones. The intuition is irresistible: if
everything must agree with its neighbors, and everything is connected, then one
value propagates across the entire system. Knowing one cell tells you all of
them. Disconnected schemas, by contrast, can carry independent values on each
island — which is exactly cohomology detecting the "holes" in your data network.

## Why this matters beyond elegance

It is tempting to file all this under "pretty mathematics," but the payoff is
practical and pointed.

**Imputation becomes geometry.** A database with missing entries is a *partial
section* of the data sheaf — a record defined only on the filled-in keys. Filling
the holes "consistently" means extending that partial section to a global one.
The sheaf viewpoint says the right way to impute missing values is to snap your
incomplete data onto the nearest *global section* — the nearest assignment that
respects every overlap constraint at once. Where mean imputation ignores
structure and nearest-neighbor imputation uses only local similarity, **sheaf
imputation** uses *exponentially many* consistency constraints simultaneously,
one for every overlapping pair of feature subsets.

This leads to a striking quantitative conjecture about how hard consistent
imputation is. If a database has its entries missing independently at a rate $r$,
and there are $C$ overlapping consistency constraints to satisfy, then the
probability that a random partial database *can* be consistently completed
behaves like

$$ P(\text{sheaf}) = (1 - r)^{C}. $$

Consistency gets exponentially rarer as the web of overlaps grows. That is not a
bug; it is the signal. Each overlap is a constraint, and constraints are exactly
the information a good imputation method should exploit. The same exponential
that makes random consistency rare is what makes a *genuinely* consistent dataset
so informative.

**Integration is a cohomology problem.** Whether two systems can be merged is
governed by whether a certain obstruction class vanishes. In the language above,
acyclic schemas (trees) always integrate, while cycles can carry "twists" — a
loop of pairwise agreements that nonetheless admits no global solution, like an
Escher staircase of data. Detecting and measuring these twists is precisely what
the first cohomology $H^1$ does, and it suggests a future where data-pipeline
debuggers report a *cohomology class* to explain why a merge failed.

**A bridge to cryptography.** Secret-sharing schemes can be modeled as sheaves
on a graph whose nodes hold shares and whose edges encode reconstruction rules.
Whether an unauthorized coalition learns anything about the secret turns out to
be a statement about whether a restriction map on global sections is injective on
the secret coordinate. Security and consistency, it turns out, are two faces of
the same gluing question.

## The takeaway

The next time a database merge fails, picture it geometrically. Your tables are
local patches of weather data over the same map. The merge fails because two
patches disagree on their overlap — and no global map can serve two masters. The
merge succeeds, *uniquely*, exactly when all patches agree on all overlaps. This
is not a rule of thumb. It is the gluing axiom of a sheaf, and it has been proved
with full rigor:

- Databases over a key space satisfy the **presheaf laws** (restriction is
  functorial).
- They satisfy **separation**: a database is determined by its sub-tables.
- They satisfy **gluing**: overlap-consistent tables merge into a unique whole.
- Mergeability is **exactly** overlap-consistency — a checkable, local criterion
  for a global property.
- Over a **connected** schema, consistency is **rigid**: one value determines
  everything.

Data integration, the most quotidian task in all of computing, is sheaf theory
in disguise. And once you know that, every spreadsheet is a little piece of
geometry waiting to be glued.
