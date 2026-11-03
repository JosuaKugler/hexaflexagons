# How the V-flex animation was worked out

The page animates the V-flex of the hexahexaflexagon following Scott Sherman's description in
*Flex Theory* (Gathering 4 Gardner 10, https://www.loki3.com/flex/g4g10/Flex-Theory.pdf):

> To perform the v-flex, fold together opposite vertices, open up the flexagon in the center,
> then slide the pats before opening it up again.

and the photo sequence (13 frames) on his *Flexing Flexagons* page
(https://www.loki3.com/flex/explore/flexing.html), read as five steps:

1. **Fold opposite corners together** (frames 1–4). The marked corner and the one opposite it are
   brought together; each half of the hexagon curls into an open tetrahedron (three triangles around
   a hollow, the centre at the tetrahedron's corner), and the two hollows share the edge from the
   centre to the joined corners.
2. **Open it into a pyramid** (frames 5–6). Holding the joined corners, the flexagon is opened at
   the centre: one tetrahedron stays as the pocket, the other opens into a square pyramid whose four
   walls are leaves of a hidden face.
3. **Slide the front wall across** (frames 7–9). The front wall is pulled out while the pocket
   collapses and a new pocket opens on the other side; the hollow now shows two leaves each of two
   other faces.
4. **Close the pyramid.** The hollow is folded shut top to bottom so that the pocket's tip lands on
   the pyramid's apex; the result is the pair of tetrahedral hollows again, on the other side.
5. **Open it from the other side.** The joined corners are pulled apart and the hollows flatten out.

## What the engine does

The paper defines the flex in pat notation:

    (a) (^c,b) (e,^d) (f) (g) (^i,h)   V ->   (b,^a) (c) (d) (^f,e) (h,^g) (i)

`index.html` applies exactly this definition (`V_FLEX` and `patFlex`). The engine reaches 3,420
arrangements with pinch and V-flexes together, as Iacob, McLean and Wang count; `tests.html` checks
this, and that the pinch flex written in the same notation reproduces the engine's own pinch flex.

## What the animation does

The nine pattern variables a to i each move as one rigid triangle (a stack of leaves). The nine
hinge points of the pattern are driven through the moves (the positions are embedded in the page as
`V_DATA`). The state after the flex is the state before it rotated 180° about the diameter through
the marked vertex, with the pieces exchanged (a↔h, b↔g, c↔i, e↔f, d fixed). So step 5 is step 1
run backwards in mirror image, and step 4 is the mirror image of step 2.

- **Step 1 is simulated**, with a constraint solver that keeps every triangle edge at length 1 and
  keeps the motion mirror-symmetric about the crease: the two opposite corners meet, each half closes
  into a regular tetrahedron with three faces, and the two share an edge. Largest edge stretch 1.7%,
  no paper through paper. With this pat structure the corners have to rise towards the side the
  notation calls the top; Sherman's "backwards" is the same move seen from his side of the paper.
- **Steps 2, 3 and 4 are not simulated.** For step 2, with the joined corners held and the centre
  closed, the point where the two stacked pairs of the opening tetrahedron meet has only two possible
  positions (a mirror pair), so it cannot move continuously: the pairs cannot part like books until
  something else gives. Searches over all rigid motions from the fold (random-tree planners,
  bidirectional planners, and a contact-respecting drive) never reached the pyramid, and the one
  route that did reach it passed a leaf through its neighbour. For step 3, a sampling search found
  routes from the pyramid to its mirror image, but every one made the layers d, e and f, which lie
  flat on one another, swap order while flat, which is a pass-through; between the two positions
  that stack must change from (top to bottom) f, e, d to d, f, e. Step 4 is step 2 in mirror image.
  Sherman lists the V-flex as a flex that needs bending; the model shows the position before each
  of these moves, explains, and jumps to the position after.
- **Step 5 is simulated** as the mirror image of step 1 run backwards.

`tests.html` checks that every animated move keeps edge lengths within 5%, has no jumps apart from
the three described moves, never passes paper through paper apart from those moves, and that the
model starts and ends on the engine's states for every V-flex the engine allows. Run `./run_tests.sh`.
