# The Last Theorem: Can Mathematics Outlive the Stars?

Imagine the deepest future. Not a thousand years from now, not a million, but $10^{100}$ years — a one followed by a hundred zeros. Every star has long since burned through its fuel. The galaxies have flown apart beyond sight of one another. Black holes have swelled, then slowly evaporated into a thin fog of particles. The universe is a cold, dilute, almost perfectly uniform darkness, drifting toward a final equilibrium that physicists call the *heat death*. In that frozen epoch, one very human question refuses to die: **how much of mathematics will we ever get to know?**

This article is about a surprisingly precise answer. It turns out that the fate of mathematical discovery is governed by a clean tension between two kinds of "finite" — a tension we might call the *finite/infinite scissor*. On one blade: every single mathematical truth can be reached in a finite amount of time. On the other blade: no finite amount of time can reach them all. Mathematics is, in a strict sense, inexhaustible — and the heat death of the universe turns that abstract inexhaustibility into a concrete, permanent loss.

## What is a theorem, really?

Before we can count theorems, we have to say what one *is*. Strip away the intuition and a theorem is astonishingly humble: it is a **finite string of symbols** — letters, numbers, logical connectives, parentheses — that can be *derived*, step by finite step, from a fixed set of starting rules and axioms. Fix your axioms (the standard foundation of modern mathematics is one such choice), fix your rules of inference, and a "theorem" is any finite statement for which a finite proof exists.

Two features of this definition do all the heavy lifting.

**First, the alphabet is finite.** Every proof anyone has ever written, or ever will write, uses a bounded stock of symbols. You never need a genuinely new symbol you cannot spell out of the ones you already have.

**Second, every proof is finite.** A proof is a finite list of finite lines. There is no such thing as an infinitely long proof; if a statement has no finite derivation, it is simply not a theorem of the system.

These two facts sound almost too modest to matter. But together they pin down the entire landscape of what can ever be proved.

## Counting the unprovable-to-exhaust

Here is the first pillar. Consider the collection of *all possible finite strings* over your fixed alphabet. There are infinitely many, of course — you can always write a longer one. But they are countable: you can line them up in a single, never-ending list with a first entry, a second, a third, and so on, missing none.

The trick to lining them up is the **shortlex order** (short-length-first, then alphabetical). List all strings of length $0$, then all strings of length $1$, then length $2$, and so on. Within each length there are only finitely many strings, so each finite "block" ends and the next begins. Sort each block alphabetically. The result is a single master list:

$$s_0,\ s_1,\ s_2,\ s_3,\ \dots$$

in which **every finite string appears exactly once, at a finite position.** Call that position the string's *index*.

Now the theorems are just a subset of these strings — the ones that happen to have proofs. A consistent, expressive foundation proves infinitely many statements (for a trivial example, it proves $0=0$, $0+1=1$, $0+2=2$, and so on forever). So the set of theorems is a countably infinite subset of a countable list. We arrive at our first result.

> **The Enumeration Theorem.** *The set of all theorems of a fixed formal system, over a finite alphabet, is countably infinite whenever the system proves infinitely many statements. Consequently there is an explicit enumeration in which each theorem occupies a unique finite position.*

This is a genuinely hopeful statement. It says there is no theorem so exotic, so far out in the wilderness of mathematics, that it lies "beyond" the list. Every truth the system can prove is *reachable*. Give a tireless machine the shortlex list and a proof-checker, and it will, sooner or later, print any particular theorem you name. For that one theorem, "sooner or later" means a **finite** number of steps.

## The discovery index

Let us make the hope concrete. Because the master list contains each string exactly once, each theorem $\theta$ has a well-defined **discovery index**: the number of enumeration steps a systematic search must take before it first prints $\theta$. This index always exists and is always finite — that is precisely what it means for $\theta$ to be a theorem in the first place.

> **The Discovery Index Theorem.** *For every theorem $\theta$ there is a unique finite index $n(\theta)$ at which a shortlex search first discovers it. Equivalently, the "time to find $\theta$" is finite for every individual theorem.*

So far, so encouraging. Fermat's Last Theorem? Finite index. The classification of finite simple groups? Finite index. Any statement that will ever be proved by anyone, ever, in this system? Finite index. Each is a fish that a patient net will eventually catch.

## The other blade of the scissor

And now the reversal. The very same enumeration that guarantees each theorem is individually reachable *also* guarantees that no finite search reaches all of them.

Pick any budget — a trillion steps, a googol steps, a googolplex steps — call it $N$. After $N$ steps the search has printed at most $N$ strings, hence at most $N$ theorems. But there are infinitely many theorems. So there is always at least one theorem — in fact infinitely many — whose discovery index exceeds $N$. No finite $N$ ever suffices.

> **The Non-Exhaustibility Theorem.** *For every finite budget $N$, the set of theorems discovered within $N$ enumeration steps is finite, while the set of theorems not yet discovered remains infinite. No finite process ever exhausts the theorems.*

This is the scissor. "Every theorem is reached at a finite step" and "no finite number of steps reaches every theorem" are not contradictory — they are two true statements about the same list, and the tension between them is the whole story. In the language of limits: the count of discovered theorems *tends to infinity*, but at no finite moment is the job *done*.

An analogy: the counting numbers $1, 2, 3, \dots$ have exactly this character. Every individual number is finite and gets named eventually if you count long enough. Yet you never finish counting. Mathematics, as a body of provable statements, is inexhaustible in precisely the way the integers are inexhaustible — not because any one of them is out of reach, but because there is no last one.

## Where physics enters

Everything above is pure mathematics; it would be true in any universe. What makes it poignant is that we do *not* live in a universe of unlimited steps. We live in one that is running down.

Physics places hard ceilings on computation. Every logical operation that flips a bit costs energy and produces at least a minimum amount of waste heat (this is Landauer's principle). The speed at which any physical system can move from one distinguishable state to the next is capped by its energy (the Margolus–Levitin bound and the related Bremermann limit). Roll these together and you get a startling estimate, first made precise by physicists studying the "computational capacity of the universe": the entire observable cosmos, treated as one giant computer running since the Big Bang, could have performed on the order of $10^{120}$ elementary logical operations in total.

Look forward instead of back, all the way to the heat death, and the accounting only gets worse. Usable energy — *free* energy, the kind that can drive a computation — is finite and dwindling. As the universe cools toward uniform thermal equilibrium, the temperature difference that any engine (or computer) needs in order to do work shrinks toward zero. Past a certain epoch, there is simply no more free energy to spend on flipping bits. Computation does not slow down gracefully forever; it *stops*.

Combine this with the two blades of our scissor and the conclusion is inescapable.

> **The Heat-Death Corollary.** *Suppose a physical process can perform at most $B$ enumeration steps over the entire future of the universe, where $B$ is finite. Then it discovers at most $B$ theorems, and — because the theorems are countably infinite — infinitely many theorems remain forever undiscovered by that process.*

Whatever the true number is — $10^{120}$, or $10^{123}$, or any other finite figure you like — it is a finite number. And a finite number, set against a countable infinity, is nothing. It is a single grain against an endless beach. The universe will run out of the physical ability to compute long, long before it runs out of theorems to find. Most of mathematics will never be known — not because it is unknowable in principle, but because there is not enough universe to know it in.

## The shape of the loss

It is worth being precise about *what kind* of loss this is, because it is subtler than "we run out of time."

We are not saying any particular theorem is unreachable. Name a theorem — any theorem — and there is a possible history of the universe in which a machine finds it. Every truth is individually within reach. The loss is *collective*: we must choose, implicitly, which finite sliver of the infinite to spend our finite budget on. The rest is not hidden or forbidden. It is merely never gotten to.

This reframes an old worry. People sometimes fear that mathematics might "end" — that we will one day prove the last interesting theorem and have nothing left to do. The scissor says the opposite. The danger was never that we would finish. The danger is that we can only ever begin. There is no last theorem in the list; there is only a last theorem *we happen to reach* before the lights go out — and which theorem that is depends entirely on the order in which we look.

## Which order should we look in?

That last observation opens a genuinely optimistic door. If the tragedy is that we get only a finite prefix of an infinite list, then the *order of enumeration* — the search strategy — is the one thing under our control. Two civilizations with identical energy budgets but different search orders will discover different mathematics.

This raises a crisp optimization question. Is there a *best* order? Here the shortlex enumeration earns its keep a second time. Ordering by length first is not an arbitrary convenience; it is essentially forced. Length is the only measure of a statement's complexity that respects the basic fact we started with — that there are only finitely many statements of each length. Any schedule that hopes to discover *everything up to a given size as quickly as possible* must, in effect, sweep out the short statements before the long ones. Shortlex is the schedule that minimizes the worst-case time to reach the entire frontier of a given complexity.

There is even room for cooperation. If two formal systems each prove infinitely many statements, then pooling their theorems — taking the union, or fairly interleaving their two search streams — cannot rescue either from non-exhaustibility (the combined set is still countably infinite and still never finished). But it *can* speed discovery by a constant factor: the interleaved search reaches any target region about as fast as whichever of the two systems was faster on its own. Mathematics done in parallel, by many interacting theories, is not immune to the scissor — but it is a better use of a finite budget.

## Coda

Strip the cosmology away and a stark, beautiful arithmetic remains. The theorems are countably infinite. Every one of them sits at a finite address in a single master list, so every one of them is, in principle, findable in finite time. Yet any finite search — and every physical search, in a universe with finite free energy, is finite — captures only a finite prefix and leaves an infinite remainder untouched.

The heat death of the universe, then, is not the death of mathematics. Mathematics was inexhaustible before the first star formed and will remain inexhaustible after the last one fades. What the heat death ends is our *access* to it. We are readers handed an infinite library and a candle that will burn for a fixed number of pages. We do not get to read the library. But we do get to choose, page by page, what to read while the candle lasts — and in that choice, and not in any final theorem, lies the whole open future of the subject.
