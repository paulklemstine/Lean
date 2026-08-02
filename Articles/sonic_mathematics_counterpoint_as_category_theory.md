# Sonic Mathematics: When Counterpoint Becomes a Category

## A rulebook made of arrows

Imagine two singers holding a conversation in melody. Each has a line of independent musical interest, yet the pair must sound coherent at every instant. Move too freely and the harmony dissolves; move too mechanically and the voices fuse into a single gesture. This tension is the heart of counterpoint.

First-species counterpoint, traditionally associated with note-against-note writing, is an unusually clean laboratory for studying that tension. Every note in one voice is paired with one note in the other. The resulting vertical intervals must be consonant, and the journey between successive pairs must obey restrictions on melodic size and parallel motion. The rules look local: inspect one sonority, inspect the next, and decide whether the move is allowed.

That sounds like a network. Sonorities are vertices, and permitted voice leadings are directed edges. It is tempting to go one step further and call this network a category: objects are consonant states, arrows are legal motions, and joining arrows represents musical composition. The temptation is mathematically productive—but it hides a trap. A legal step followed by another legal step need not itself be a legal single step.

The way out is not to abandon categories. It is to distinguish an immediate move from a journey.

## The seven consonant interval states

Represent a two-voice sonority by an ordered pair $x=(x_0,x_1)$ of integer pitches, measured in semitones. Its directed vertical interval is

$$
\nu(x)=x_1-x_0.
$$

The strict simple consonances from unison through the octave are represented by the absolute semitone distances

$$
C=\{0,3,4,7,8,9,12\}.
$$

These are unison, minor third, major third, perfect fifth, minor sixth, major sixth, and octave. Among them, the perfect consonances are

$$
P=\{0,7,12\}.
$$

Thus this explicit model has seven interval objects, not twelve. The count is not caused by identifying two differently named intervals: the semitone realizations $0,3,4,7,8,9,12$ are all distinct. Any claim about a twelve-object counterpoint structure therefore needs additional musical state—perhaps scale degree, register, metrical position, or approach direction. It does not follow from the standard simple-consonance list alone.

Now define a local rule. A motion from $x=(x_0,x_1)$ to $y=(y_0,y_1)$ is **stepwise** when each voice moves by at most a whole tone:

$$
|y_0-x_0|\le 2,
\qquad
|y_1-x_1|\le 2.
$$

The motion is **similar** when both voices move strictly upward or both move strictly downward. Finally, call the motion **permitted** when four conditions hold:

1. $|\nu(x)|$ belongs to $C$;
2. $|\nu(y)|$ belongs to $C$;
3. the motion is stepwise; and
4. it is not similar motion from one perfect consonance to another.

This deliberately compact rule is a mathematical test model, not a claim to encode every historical nuance of species counterpoint. Its value lies in making every assumption visible.

## Rest is an identity

Categories require an identity arrow at every object: a do-nothing move that can be placed before or after any journey. Music supplies a natural candidate. If a consonant dyad remains stationary, both voices move by $0$ semitones. The move is stepwise, and it is not strictly upward or downward. Therefore every consonant sonority has a permitted stationary motion.

This is the first encouraging sign. Musical rest behaves like categorical identity.

But categories also require composition. If there is an arrow from $x$ to $y$ and an arrow from $y$ to $z$, there must be an arrow from $x$ to $z$. Here the local rule fails.

Take

$$
x=(0,3),\qquad y=(2,5),\qquad z=(4,7).
$$

Each dyad is a minor third. From $x$ to $y$, both voices rise by $2$ semitones; from $y$ to $z$, both rise by another $2$. The endpoints are imperfect consonances, so the ban on similar motion between perfect consonances does not apply. Both moves are permitted.

Yet the direct displacement from $x$ to $z$ is $4$ semitones in each voice. That exceeds the stepwise bound. Hence the direct motion is not permitted. In symbols, if $M(x,y)$ means that the one-step motion is permitted, then

$$
M(x,y)\land M(y,z)\land \neg M(x,z)
$$

holds for this explicit triple.

This single musical phrase settles a structural question. The raw one-step relation is not transitive, so it cannot be exactly the arrow relation of a thin category, or equivalently the comparison relation of a preorder. The obstacle is not obscure: two small melodic steps can add up to one large leap.

## From moves to journeys

The correction is conceptually simple. Define $x\leadsto y$ to mean that $y$ can be reached from $x$ by a finite sequence of permitted motions, allowing a sequence of length zero. Thus

$$
x=x^{(0)},x^{(1)},\ldots,x^{(r)}=y
$$

for some $r\ge 0$, with every adjacent motion permitted.

This reachability relation has exactly the properties the one-step rule lacked. It is reflexive because the empty journey reaches a state from itself. It is transitive because a journey from $x$ to $y$ can be concatenated with a journey from $y$ to $z$. Consequently, reachability is a preorder.

A preorder determines a **thin category**: there is one arrow from $x$ to $y$ when $x\leadsto y$, and no arrow otherwise. “Thin” means there is never more than one arrow between a fixed pair of objects. This does not say that there is only one musical route. There may be many distinct sequences of sonorities connecting the same endpoints. Rather, the thin category forgets the internal itinerary and records only whether a connection exists.

That distinction is musically revealing. The local graph remembers gestures; the generated thin category remembers accessibility. One is a map of roads, the other a yes-or-no atlas of destinations.

## A complete seven-state experiment

To isolate interval behavior from register and transposition, place the lower voice at pitch $0$ and realize each consonance $c\in C$ as the canonical dyad $(0,c)$. Between two canonical dyads, the bass is stationary, so the upper voice may change by at most $2$ semitones. Similar motion cannot occur because the bass does not move strictly. Therefore a canonical one-step motion exists precisely when

$$
|d-c|\le 2
$$

for $c,d\in C$.

The complete directed table contains exactly fifteen permitted ordered motions, including the seven stationary motions. Besides those identities, there are eight directed changes:

$$
3\leftrightarrow4,
$$

and every pair among $7,8,9$ is connected in both directions. In particular, minor third can move to major third, and major third can move back to minor third. So reachability on named intervals is not antisymmetric: two distinct objects may reach each other. It is a preorder, not yet a partial order.

If a partial order is desired, mutually reachable states must be collapsed into equivalence classes. Define $c\sim d$ when both $c\leadsto d$ and $d\leadsto c$. The quotient by this relation is partially ordered. In the present canonical model, the classes visible from the table are

$$
\{0\},\quad \{3,4\},\quad \{7,8,9\},\quad \{12\}.
$$

This is a useful warning against counting objects before specifying what an object contains. Seven named consonances, fifteen local arrows, and four mutual-reachability classes are all correct counts—but they answer different questions.

## Why this bridge matters

The categorical viewpoint does more than translate musical words into mathematical ones. It separates three levels that are often blurred.

First comes **syntax**: the local rule deciding whether one sonority may follow another. Second comes **dynamics**: the directed graph of immediate possibilities. Third comes **global structure**: the reachability preorder generated by all finite paths. Composition belongs naturally to the third level, not the first.

The same pattern appears in robotics, where a legal control input is not the same as a complete reachable trajectory; in chemistry, where one reaction step is not the same as conversion through intermediates; and in language, where one grammatical rewrite is not the same as derivability through many rewrites. Counterpoint provides an unusually audible example. We can hear the difference between a step and a path.

It also clarifies what a richer theory must add. Historical first-species counterpoint includes boundary conditions, treatment of beginnings and endings, diatonic spelling, register, melodic contour, and context-sensitive restrictions. Adding such data changes the state space and may change the quotient dramatically. A twelve-state structure might emerge from an enriched model, but twelve cannot be conjured from seven interval names.

## A structural echo: leaves and forbidden markings

The same local-to-global philosophy appears in a second, abstract setting. Consider a finite tree $G$: a connected graph without cycles. If it has $n$ vertices, then it has $n-1$ edges. Since every edge contributes $1$ to the degree of each endpoint, the handshaking identity gives

$$
\sum_{v\in G}\deg(v)=2(n-1).
$$

This immediately forces a leaf. If every vertex had degree at least $2$, the degree sum would be at least $2n$, contradicting $2(n-1)<2n$. Thus every nonempty finite tree has some vertex $v$ with $\deg(v)\le1$.

Now suppose a tree diagram carries a singleton admissibility rule arising from a dominant-weight construction: a marked singleton $\{v\}$ is admissible exactly when $\deg(v)\ge2$. The leaf theorem then yields a global obstruction: every nonempty tree contains a vertex whose singleton marking is not dominant. In the notation customary for such corrections, there is a $v$ for which $\lambda_{\{v\},I}=2\rho-\beta_I-\alpha_v$ does not lie in the dominant cone $P^+$. The proof uses no detailed case analysis of tree shapes; averaging alone finds the forbidden site.

This result is mathematically separate from the counterpoint model, but it reinforces the same message. Local eligibility rules are constrained by global combinatorial structure. In music, path closure repairs a local relation that cannot compose. In a tree, the degree sum guarantees that some local marking cannot qualify.

## The final cadence

The central counterpoint result is therefore both negative and constructive. The permitted one-step motions do not themselves form a category, because they are not closed under composition. Their finite-path closure does form a thin category, because reachability is reflexive and transitive. In the standard canonical interval model there are seven objects and fifteen one-step arrows, with reversible motion between the two thirds and among the fifth and sixth region.

The lesson is broader than counterpoint. When local rules are presented as arrows, one must ask whether an arrow means “one move” or “some finite process.” Categories demand the latter kind of composability. Music supplies the local gestures; mathematics supplies the closure that turns gestures into journeys.

And that is the sonic mathematics at the heart of the construction: a melody does not merely occupy states. It travels through them, and the algebra of travel begins where a single step ends.
