# The Multiplication Table Hidden Inside Every Group

## Why a group's "atomic weight" is never an accident

Chemists have a periodic table because atoms are built from smaller, conserved pieces. Hydrogen is hydrogen because it has exactly one proton; carbon is carbon because it has six. Crucially, two different versions of the *same* element can have *different* masses — carbon-12 and carbon-14 are **isotopes**, identical in chemistry but different on the scale. The number of protons fixes the chemistry; the mass is a separate, independent fact.

Mathematicians have their own periodic table. Its "atoms" are **finite groups** — the abstract structures that capture symmetry, from the rotations of a snowflake to the shuffles of a deck of cards. And just like atoms, every finite group is built from a unique list of indivisible pieces called its **composition factors**. The natural question, borrowing the chemist's intuition, is: *can two groups have the same composition factors but different sizes?* Can groups have isotopes?

The answer, it turns out, is a flat and slightly surprising **no** — and the reason is a single, elegant, completely elementary identity about how subgroups nest inside one another. This article is the story of that identity, which we call the **subgroup-index telescope**. It is the arithmetic engine that forces a group's size to be the *product* of its building blocks, with nothing left over for an "isotope" to hide in.

## Groups, subgroups, and the index

Let's build the vocabulary from scratch, assuming nothing.

A **group** $G$ is a collection of "moves" you can do and undo — symmetries — that you can chain together. The number of distinct moves is the group's **order**, written $\lvert G\rvert$ or $\mathrm{Nat.card}\,G$. For a finite group this is just a positive whole number, its "atomic weight."

A **subgroup** $H \le G$ is a smaller self-contained collection of moves inside $G$: closed under chaining and undoing. The hands of a clock have $12$ positions, forming a group; the "even hours" $\{0,2,4,6,8,10\}$ form a subgroup of size $6$.

The single most important number relating a subgroup to its parent is the **index**, written $[G:H]$. It counts how many shifted copies — called **cosets** — of $H$ are needed to tile all of $G$. Lagrange's theorem, the first real theorem anyone learns about groups, says these copies are all the same size and tile $G$ perfectly:

$$\lvert G\rvert = [G:H]\cdot \lvert H\rvert.$$

For the clock, the even hours $H$ have index $[G:H]=2$: the two cosets are "even hours" and "odd hours," and $12 = 2 \cdot 6$.

There is also a **relative index**. If $K \le H \le G$ is a tower of three nested groups, then $[H:K]$ measures how $K$ sits inside $H$, ignoring $G$ entirely. The basic law of these towers is **multiplicativity of the index**:

$$[G:K] = [G:H]\cdot[H:K].$$

Indices multiply along a tower the way denominators cancel in a chain of fractions: $\tfrac{a}{c} = \tfrac{a}{b}\cdot\tfrac{b}{c}$. This humble rule is the seed of everything that follows.

## A chain of subgroups, and the telescope

Now imagine not three groups but a whole staircase of them — a **monotone chain**:

$$H_0 \le H_1 \le H_2 \le \cdots \le H_n.$$

Between each consecutive pair sits a relative index $[H_{i+1}:H_i]$, the "step size" of that stair. The natural question is: if you know all the step sizes, what do you know about the *total climb* from the bottom $H_0$ to the top $H_n$?

The answer is the **telescope identity**, the heart of this work:

$$\prod_{i=0}^{n-1}\,[H_{i+1}:H_i] \;=\; [H_n:H_0].$$

In words: **multiply all the individual step sizes and you get the single overall index from bottom to top.** The intermediate groups $H_1,\dots,H_{n-1}$ vanish from the answer, exactly the way the middle terms cancel in a telescoping sum like $(a_1-a_0)+(a_2-a_1)+\cdots$. Here the cancellation is multiplicative: each $\lvert H_i\rvert$ appears once in a numerator and once in a denominator, and only the endpoints survive.

This is the result we formally verified, under the name `relIndex_prod_telescope`. The proof is an induction on the length of the chain: peel off the last step, apply the result to the shorter chain that remains, and glue the final stair back on using index multiplicativity. No deep theory is needed — just Lagrange's law applied $n$ times and watched carefully.

## From the telescope to a group's atomic weight

The telescope becomes powerful the moment we anchor the staircase at the two natural endpoints every group possesses: the **trivial subgroup** $\{e\}$ (written $\bot$), containing only the "do nothing" move, and the **whole group** $G$ itself (written $\top$).

A chain that starts at the bottom and climbs all the way to the top,

$$\bot = H_0 \le H_1 \le \cdots \le H_n = \top,$$

is exactly the kind of staircase that **composition series** use. Plugging the endpoints into the telescope, and using that the index over the trivial subgroup is just the order of the group ($[G:\bot]=\lvert G\rvert$), gives the punchline we verified as `prod_relIndex_eq_card_of_bot_top`:

$$\prod_{i=0}^{n-1}\,[H_{i+1}:H_i] \;=\; \lvert G\rvert.$$

**The order of the group is the product of the step sizes — full stop.** There is no freedom, no slack, no remainder. Along the way we also recorded the same fact in two other costumes:

- A **cardinality** version, `card_telescope`:
  $$\lvert H_n\rvert = \lvert H_0\rvert \cdot \prod_{i=0}^{n-1}[H_{i+1}:H_i],$$
  valid even for infinite groups (where both sides are read as $0$ by convention).
- A **mixed** version, `index_prod_telescope`, that keeps the top of the chain below $G$:
  $$\Big(\prod_{i=0}^{n-1}[H_{i+1}:H_i]\Big)\cdot[G:H_n] = [G:H_0],$$
  and its specialization `prod_relIndex_eq_index_of_top` when the chain already reaches $\top$.

## The "no isotopes" theorem

Now we can return to chemistry and deliver the verdict.

A **composition series** of a finite group is a maximal staircase from $\bot$ to $\top$ in which every step is as small as it can possibly be — each step size is a **simple group**, an "atom" with no smaller normal pieces inside. The celebrated Jordan–Hölder theorem says the *list of these atomic steps is unique*: no matter how you build the staircase, you always meet the same collection of simple groups (the **composition factors**). They are the group's chemical formula.

The telescope now hands us the mass law for free. Since the order is the product of the step sizes, and the steps are exactly the orders of the composition factors $S_1,\dots,S_k$:

$$\lvert G\rvert \;=\; \prod_{i=1}^{k} \lvert S_i\rvert.$$

And therefore: **any two finite groups with the same multiset of composition factors have the same order.** A group's size is a *function* of its formula. There is no room for a "carbon-14" — no two groups can share a chemical formula yet differ in mass. The chemical analogy, so productive everywhere else, breaks at exactly one joint, and the break is a *theorem*, not an accident. In atoms, atomic number and mass are independent; in groups, mass is determined by the formula.

This is the conceptual payoff the telescope was built to support. It upgrades a special case — that prime-order groups have no genuine isotopes — to the entire periodic table of finite groups.

## Worked example: the symmetries of a square's diagonals

Take $S_4$, the group of all $24$ ways to shuffle four objects — equivalently, the rotation symmetries of a regular octahedron. It has a beautiful composition series:

$$\bot \;\le\; V_4 \;\le\; A_4 \;\le\; S_4,$$

where $V_4$ is the four-element "Klein" group of double swaps and $A_4$ is the $12$ even permutations. The step sizes are:

$$[V_4:\bot]=4,\qquad [A_4:V_4]=3,\qquad [S_4:A_4]=2.$$

Wait — $V_4$ itself is not simple; refine its bottom step $\bot \le \langle(12)(34)\rangle \le V_4$ into two steps of size $2$. The fully refined step sizes are then $2,2,3,2$, and the telescope predicts

$$2\cdot 2\cdot 3\cdot 2 = 24 = \lvert S_4\rvert,$$

precisely the order of $S_4$. The composition factors are $\mathbb{Z}_2,\mathbb{Z}_2,\mathbb{Z}_3,\mathbb{Z}_2$ — three "hydrogen-2" pieces and one "lithium-3" piece — and their product of orders reconstructs the mass exactly. Any other group built from this same shopping list (for instance the cyclic group $\mathbb{Z}_{24}$ has a *different* list but also order $24$; the dihedral group of the $12$-gon, etc.) is forced to weigh $24$ if and only if it shares the list.

## Why build it this way?

A reader steeped in algebra might object that the order law "follows from Lagrange." It does — but the *form* matters enormously for what comes next. We deliberately built the telescope as a **standalone, non-circular foundation**. It invokes no Jordan–Hölder machinery, no abstract lattice theory, nothing but the multiplicativity of the index applied along a chain. That austerity is the point: the telescope is meant to be the load-bearing beam beneath a future formal proof of Jordan–Hölder itself, and a beam that secretly leaned on the building it supports would be useless.

This is the same discipline that makes the periodic table of *atoms* trustworthy: you establish conservation of charge and mass-number *before* you classify the elements, not after. Here, conservation of "product of step sizes" is established first, in complete generality, and the classification of groups can later rest on it without circularity.

## The bigger picture

The telescope is small, but it sits at a busy crossroads.

- **Schreier refinement**, the statement that any two subgroup chains can be refined to "match up," is exactly the assertion that inserting an intermediate subgroup splits one step size into a product of two with the *same total* — which is the telescope applied to a length-two subchain.
- **Module length** — the analogue of group order for the building blocks of linear algebra — obeys the very same tower law, with "index" replaced by "length of a quotient." The identical proof, abstracted one notch, unifies the group and module worlds.
- **Minimal faithful representations**: how efficiently a group can be encoded as permutations is graded by similar index data, turning qualitative facts into measurable spectra.

Each of these is a doorway the telescope quietly unlocks. But the headline remains the one a chemist can appreciate at a glance: in the periodic table of symmetry, you cannot weigh a group wrong. Its mass is dictated, multiplicatively and exactly, by the atoms it is made of. There are no isotopes — and now we know precisely why.
