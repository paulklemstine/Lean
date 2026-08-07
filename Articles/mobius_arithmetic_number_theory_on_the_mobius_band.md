# Numbers with a Twist: What Happens When You Do Arithmetic on a Möbius Band

## A strip of paper and a question

Take a long strip of paper, give one end a half-turn, and glue the ends together. You have made a Möbius band — the standard party trick of topology, the surface with only one side. Run your finger along it and you come back to where you started, but upside down.

Now ask a strange question. The integers $\dots, -2, -1, 0, 1, 2, \dots$ live on a line. What if we made them live on a Möbius band instead? What if $n$ and $-n$ were secretly *the same number*, seen from two opposite orientations — the way the two "sides" of the band are secretly the same side?

This is not an idle fantasy. The Möbius band is the quotient of a cylinder by a free involution: the map that flips you to the other side and slides you halfway round. Number theory is full of quotients too — the integers modulo $n$, ideal class groups, Galois covers of prime spectra. So the question has a precise algebraic form: **what number system do you get if you take integers-with-orientation and impose the Möbius identification?** And, once you have it: does it have unique factorization? What are its primes? What is its zeta function, and where are that function's zeros?

The answers turn out to be much more interesting than the naive hope, and they teach a lesson that reaches far beyond this one construction. The short version is:

> **You cannot twist a number system by twisting its underlying set. A twist that is only an identification of points is invisible to arithmetic. To make a twist matter, you must put it in the multiplication.**

This article tells the story of that lesson, and of the ring that finally *does* carry a genuine twist.

## Building the Möbius integers

Start with the **oriented integers**: pairs $(n, \varepsilon)$ where $n$ is an ordinary integer, the *magnitude*, and $\varepsilon \in \{+1, -1\}$ is an *orientation*. Picture this as a cylinder: the integer line, doubled, one copy for each way of walking along it.

Now glue with a half-turn. Impose the **Möbius identification**
$$(n, +1) \;\sim\; (-n, -1).$$
Walking to $n$ facing forwards is the same as walking to $-n$ facing backwards. The set of equivalence classes is the ring of **Möbius integers**, written $\widetilde{\mathbb{Z}}$.

The identification is exactly the statement that two oriented integers are equivalent when their *signed values* $\varepsilon \cdot n$ agree. So $\widetilde{\mathbb{Z}}$ carries a well-defined function to $\mathbb{Z}$, sending the class of $(n,\varepsilon)$ to $\varepsilon n$.

The first thing to check is that the gluing really is Möbius-like — that nothing collapses more than it should. It doesn't. Define the **deck transformation** on oriented integers by
$$\tau(n, \varepsilon) = (-n, -\varepsilon).$$

> **Free Double Cover Theorem.** The map $\tau$ is an involution ($\tau^2 = \mathrm{id}$) with no fixed points, two oriented integers have the same Möbius class if and only if they are equal or exchanged by $\tau$, and consequently *every* fibre of the quotient map has exactly two points. Equivalently, $\widetilde{\mathbb{Z}}$ is the orbit space of a free action of the group $\mathbb{Z}/2$ on the oriented integers.

That is the exact algebraic mirror of "the Möbius band is the annulus modulo a free involution". No point is its own mirror image; the cover is unramified everywhere. Notice in particular that $(0,+1)$ and $(0,-1)$ are *not* identified with each other — they are exchanged by $\tau$, and they are two distinct oriented integers with the same class. Nothing is special about zero at the level of the cover.

Next, arithmetic. Addition and multiplication have to be performed *through* the identification: to add two Möbius integers you push them to their signed values, add there, and put the result back. The same for multiplication. These operations are well defined and satisfy every commutative ring axiom.

And here comes the punchline of the first act.

> **Structure Theorem.** The ring of Möbius integers is isomorphic to the ordinary integers: $\widetilde{\mathbb{Z}} \cong \mathbb{Z}$, by the signed-value map.

The half-twist vanished. Every fibre of the cover has two points, the deck involution has no fixed point, the topology is genuinely Möbius — and the ring you get at the end is just $\mathbb{Z}$ again, wearing a disguise.

## What survives: the orientation group

Not quite everything is lost. The orientation reappears as the **unit group**: a Möbius integer is invertible exactly when it is $\pm 1$, so the units form a cyclic group of order two. This $\mathbb{Z}/2$ is the algebraic residue of the half-twist — the same $\mathbb{Z}/2$ that is the fundamental group of the Möbius band, and the same $\mathbb{Z}/2$ that was acting freely upstairs.

The orientation is not merely present; it *splits off cleanly*.

> **Polar Decomposition.** Every nonzero Möbius integer factors uniquely as an orientation times a positive radius. Multiplicatively, the nonzero Möbius integers are the direct product $\mathbb{Z}/2 \times \{1, 2, 3, \dots\}$.

So the Möbius double cover is **multiplicatively trivial**: as a bundle of orientations over the radii, it has a global section, namely "always choose the positive orientation". This single structural fact explains every subsequent finding.

## Testing the conjectures

The original programme came with a list of bold predictions. Each one can now be adjudicated, and the pattern of true-and-false is the real content.

**Class number one — true, but for a boring reason.** $\widetilde{\mathbb{Z}}$ is a principal ideal domain (every ideal is generated by one element, unique up to orientation), hence its class group is trivial. True, but inherited wholesale from $\mathbb{Z}$.

**Primes double-cover the rational primes — true on elements.** Call $n^{+}$ the class of $(n, +1)$ and $n^{-}$ the class of $(n, -1)$; these are the two oriented copies of the radius $n$, and $n^{-} = -n^{+}$. A Möbius integer is prime exactly when its *radius* (the absolute value of its signed value) is an ordinary prime, so for each rational prime $p$ there are exactly two Möbius primes of radius $p$, namely $p^{+}$ and $p^{-}$. The count of prime elements over $p$ is exactly $2$.

**Primes double-cover the prime spectrum — false.** This is the crucial distinction. $p^{+}$ and $p^{-}$ are different *elements*, but they generate the *same ideal*, hence the same point of the prime spectrum. In fact the comparison map $\operatorname{Spec} \widetilde{\mathbb{Z}} \to \operatorname{Spec} \mathbb{Z}$ is an order isomorphism: a single cover, not a double one. Doubling happens on elements — where it is a torsor under the orientation group — and evaporates on points.

The correct general statement is this: any two Möbius integers of the same nonzero radius differ by a *unique* unit, so each nonzero fibre of the radius map is a $\mathbb{Z}/2$-torsor. That, and not a splitting of primes, is what "double cover" means here.

**Factoring $6$ two ways — true, but not a failure of unique factorization.** We have both
$$6 = 2^{+} \cdot 3^{+} \qquad\text{and}\qquad 6 = 2^{-} \cdot 3^{-},$$
and these are genuinely different as *oriented data*: $2^{+} \ne 2^{-}$. A complete enumeration shows that $6$ has exactly four ordered factorizations into two Möbius primes, namely $(2^{+},3^{+}), (3^{+},2^{+}), (2^{-},3^{-}), (3^{-},2^{-})$. But $2^{+}$ and $2^{-}$ are associates (they differ by the unit $-1$), so unique factorization is untouched:

> **Unique Factorization up to Orientation.** Any two prime factorizations of the same Möbius integer agree after a permutation, each matched pair differing at most by an orientation flip. Consequently, the multiset of radii appearing in a prime factorization is a complete invariant: it is the same for all factorizations.

**The ring is non-Ore, producing exotic zeta zeros — false.** $\widetilde{\mathbb{Z}}$ is a commutative domain, so any two nonzero elements trivially have a common nonzero multiple. There is no non-commutative pathology to exploit.

## The zeta function that refused to move

Every arithmetic object deserves a zeta function. Since each nonzero radius carries exactly two oriented points while the centre carries only one, the Dirichlet series of $\widetilde{\mathbb{Z}}$ is
$$\widetilde{\zeta}(s) \;=\; \sum_{x \ne 0} |x|^{-s} \;=\; 2\zeta(s),$$
for $\operatorname{Re} s > 1$, where $\zeta$ is the Riemann zeta function. Twice — not squared.

Everything follows. $\widetilde{\zeta}$ and $\zeta$ have exactly the same zeros. The Möbius zeta function does have zeros off the critical line, at $s = -2, -4, -6, \dots$ — but these are the *trivial* zeros, inherited verbatim from $\zeta$, and nothing to do with the twist. And the Möbius Riemann hypothesis is *equivalent* to the classical Riemann hypothesis: multiplying a function by $2$ cannot create, destroy, or move a single zero.

Nor is this an accident of the number two.

> **Oriented Zeta Theorem.** Let $N$ be any "norm" on any set whose nonzero values are each attained exactly $k$ times, for a fixed $k \ge 1$. Then for $\operatorname{Re} s > 1$ its Dirichlet series is $\sum N(x)^{-s} = k\,\zeta(s)$, and the corresponding Riemann hypothesis is equivalent to the classical one — for every $k$. Moreover, every $k \ge 1$ is realised, so the constant is sharp.

A cover whose multiplicity is a *constant* contributes an additive constant to $\log \zeta$, never a multiplicity inside the Euler factors. Genuine covers of $\operatorname{Spec} \mathbb{Z}$ *square* the zeta function; the Möbius cover merely doubles it. Concretely, at $s = 2$: $\widetilde{\zeta}(2) = \pi^2/3$, whereas $\zeta(2)^2 = \pi^4/36$. Those two numbers are different, and their difference is the whole story.

## Where the twist really lives

Is arithmetic on the Möbius band therefore vacuous? No — but the interesting content is *negative* and surprisingly sharp.

Multiplication lifts to the cover in the friendliest possible way: the magnitude of a product is the product of magnitudes, the orientation of a product is the product of orientations. The two coordinates never talk to each other.

Addition is radically different.

> **Additive Obstruction Theorem.** There is no pair of functions computing Möbius addition coordinatewise on the cover — no function $g$ of the two magnitudes and function $h$ of the two orientations with $(m,\varepsilon) + (n,\delta) = (g(m,n), h(\varepsilon,\delta))$. Indeed, more strongly: even if the orientation of the sum is allowed to depend arbitrarily on *everything*, the magnitude of the sum can never be computed from the two magnitudes alone.

The proof is a two-line calculation with $1^{+} + 1^{+} = 2$ and $1^{+} + 1^{-} = 0$: the same pair of magnitudes, two different answers, and $|2| \ne |0|$. That is the whole obstruction, and it is fatal. Addition mixes the two strata of the band; multiplication respects them. This is exactly why the twist survives in the unit group (multiplicative) and dies in the ring structure (which needs addition).

The same computation generalises into a usable *criterion*: if a binary operation is computable separately on magnitudes and orientations, then its absolute value must be unchanged when either input is negated. Multiplication passes; addition, subtraction, $(m,n) \mapsto m + n^2$, and even $(m,n) \mapsto m+1$ all fail. The criterion is necessary but *not* sufficient: the operation "$m\cdot n$ if $m$ is even, $|m\cdot n|$ otherwise" has a completely orientation-blind absolute value and still admits no such lift, because the obstruction it carries is a sign cocycle rather than a size condition.

And is the Möbius twist itself special? Yes, uniquely so.

> **Classification of Twists.** If an additive symmetry of the integer line has finite order dividing $k > 0$, then it is either the identity or negation, and negation can only occur when $k$ is even. In particular there is no genuine $\mathbb{Z}/k$-Möbius arithmetic for odd $k \ge 3$.

The half-twist is the *only* nontrivial finite twist available on $\mathbb{Z}$. There is no "third-of-a-turn" number system.

## The honest twist: the oriented double

If a set-level identification cannot carry a twist, the diagnosis is clear: **store the orientation in the multiplication**. Adjoin an abstract orientation symbol $\tau$ with $\tau^2 = 1$, and form the **oriented double**
$$\mathcal{O} = \mathbb{Z}[\tau]/(\tau^2 - 1) \;\cong\; \{(u,v) \in \mathbb{Z}\times\mathbb{Z} \;:\; u \equiv v \ (\mathrm{mod}\ 2)\},$$
the group ring of the orientation group, realised concretely as the index-two subring of $\mathbb{Z}\times\mathbb{Z}$ cut out by a parity condition (via $u = a+b$, $v = a-b$ for $a + b\tau$). The two coordinates *are* the two orientations, and the deck involution is the coordinate swap $\tau \mapsto -\tau$.

Now everything the original conjecture wanted actually happens.

- $\mathcal{O}$ is **not** a domain: $(1+\tau)(1-\tau) = 0$. Hence $\mathcal{O} \not\cong \mathbb{Z}$ and $\mathcal{O} \not\cong \widetilde{\mathbb{Z}}$. The twist is a genuine invariant at last.
- The orientation group grows from $\mathbb{Z}/2$ to the Klein four-group: the units are exactly $\{\pm 1, \pm\tau\}$.
- There are **exactly two** ring homomorphisms $\mathcal{O} \to \mathbb{Z}$, $a + b\tau \mapsto a \pm b$ — the two orientations, exchanged by the deck involution, whose fixed ring is precisely the diagonal copy of $\mathbb{Z}$.
- The prime spectrum **really is** a double cover, branched at exactly one prime. For each odd prime $p$ there are two distinct maximal ideals $P^{+}(p) \ne P^{-}(p)$ lying over $p$, meeting in $(p)$, with split residue ring $\mathcal{O}/p\mathcal{O} \cong \mathbb{F}_p \times \mathbb{F}_p$. Over $p = 2$ the two coincide, $P^{+}(2) = P^{-}(2)$, with $P^{+}(2)^2 \subseteq (2) \subsetneq P^{+}(2)$ and a non-reduced residue ring in which $\tau - 1$ is nilpotent. Counting points of the fibre: two over every odd prime, one over $2$.
- The branch locus is visible from another direction too: $\mathcal{O}$ sits with index two in its normalisation $\mathbb{Z}\times\mathbb{Z}$, and the quotient is $\mathbb{Z}/2$. The conductor of the order *equals* the branch locus.

The zeta function now behaves as a double cover should.

> **Spectral Zeta Theorem.** Give each point of the spectrum of $\mathcal{O}$ over a rational prime $p$ the Euler factor $(1-p^{-s})^{-1}$. For $\operatorname{Re} s > 1$ the resulting product is
> $$\zeta_{\mathcal{O}}(s) \;=\; \zeta(s)^2 \left(1 - 2^{-s}\right).$$

Every odd Euler factor is *squared* — that is what a real two-to-one cover does — and the factor at the branch prime $2$ is corrected exactly once. Expanded as a Dirichlet series the coefficients are $d(n) - d(n/2)$, with $d$ the divisor function and $d(n/2)$ read as $0$ for odd $n$: the counts $1,1,2,1,2,2,2,1,3,2,2,2,\dots$ for $n = 1,\dots,12$. These are non-negative, and at prime index they genuinely count ideals: two ideals of index $p$ for odd $p$, exactly one of index $2$. The value at $s=2$ is $\zeta_{\mathcal{O}}(2) = \pi^4/48 \approx 2.0294$, sharply distinct from $\widetilde{\zeta}(2) = \pi^2/3 \approx 3.2899$.

And now the zeros finally move. The ramified factor $1 - 2^{-s}$ vanishes at
$$s_0 = \frac{2\pi i}{\log 2} \approx 9.0647\,i,$$
which is a zero of $\zeta_{\mathcal{O}}$ but *not* of $\zeta$. So the original slogan — "the oriented zeta function has zeros off the critical line" — is literally true, and for the first time non-trivially so. It is true not because of any exotic non-commutative behaviour, but because of **ramification**: the branch point at the prime $2$ is what creates the new zeros. Yet the twist is disciplined: all the extra zeros lie on the line $\operatorname{Re}s = 0$, so *inside the critical strip* the oriented Riemann hypothesis is exactly equivalent to the classical one. A double cover moves the zero set only through its branch locus, and only outside the strip.

## The moral

Three sentences summarise the whole programme.

A $\mathbb{Z}/2$ symmetry imposed as an identification of a *set* is multiplicatively trivialisable and additively non-liftable; the resulting "twisted" ring is not twisted at all, and its zeta function is a constant multiple of the old one, so no zero can move.

A $\mathbb{Z}/2$ symmetry imposed on the *multiplication* — a group ring, an order in a product of number fields — produces a genuine branched double cover of the prime spectrum, squares the Euler factors, and creates new zeros supplied by its branch locus.

The difference between them is exactly the difference between a topological twist and an arithmetic one, and the boundary between the two is the failure of addition to lift.

That is a satisfying place to end up. We set out to do arithmetic on the Möbius band, and found that the band's beautiful half-twist slides right off the integers like water. But in learning precisely *why* it slides off, we learned exactly what a twist must be made of to stick — and, having built one out of the right material, we watched the zeros move.
