TextBufferCore = require '../src/text-buffer-core'

describe "Marker", ->
  [buffer, markerCreations] = []
  beforeEach ->
    buffer = new TextBufferCore(text: "abcdefghijklmnopqrstuvwxyz")
    markerCreations = []
    buffer.on 'marker-created', (marker) -> markerCreations.push(marker)

  describe "creation", ->
    describe "TextBufferCore::markRange(range, properties)", ->
      it "creates a marker for the given range with the given properties", ->
        marker = buffer.markRange([[0, 3], [0, 6]])
        expect(marker.getRange()).toEqual [[0, 3], [0, 6]]
        expect(marker.getHeadPosition()).toEqual [0, 6]
        expect(marker.getTailPosition()).toEqual [0, 3]
        expect(marker.isReversed()).toBe false
        expect(marker.hasTail()).toBe true
        expect(markerCreations).toEqual [marker]

      it "allows a reversed marker to be created", ->
        marker = buffer.markRange([[0, 3], [0, 6]], isReversed: true)
        expect(marker.getRange()).toEqual [[0, 3], [0, 6]]
        expect(marker.getHeadPosition()).toEqual [0, 3]
        expect(marker.getTailPosition()).toEqual [0, 6]
        expect(marker.isReversed()).toBe true
        expect(marker.hasTail()).toBe true

      it "allows an invalidation strategy to be assigned", ->
        marker = buffer.markRange([[0, 3], [0, 6]], invalidate: 'inside')
        expect(marker.getInvalidationStrategy()).toBe 'inside'

      it "allows custom state to be assigned", ->
        marker = buffer.markRange([[0, 3], [0, 6]], foo: 1, bar: 2)
        expect(marker.getState()).toEqual {foo: 1, bar: 2}

    describe "TextBufferCore::markPosition(position, properties)", ->
      it "creates a tail-less marker at the given position", ->
        marker = buffer.markPosition([0, 6])
        expect(marker.getRange()).toEqual [[0, 6], [0, 6]]
        expect(marker.getHeadPosition()).toEqual [0, 6]
        expect(marker.getTailPosition()).toEqual [0, 6]
        expect(marker.isReversed()).toBe false
        expect(marker.hasTail()).toBe false
        expect(markerCreations).toEqual [marker]

  describe "direct manipulation", ->
    [marker, changes] = []

    beforeEach ->
      marker = buffer.markRange([[0, 6], [0, 9]])
      changes = []
      marker.on 'changed', (change) -> changes.push(change)

    describe "::setHeadPosition(position, state)", ->
      it "sets the head position of the marker, flipping its orientation if necessary", ->
        marker.setHeadPosition([0, 12])
        expect(marker.getRange()).toEqual [[0, 6], [0, 12]]
        expect(marker.isReversed()).toBe false
        expect(changes).toEqual [{
          oldHeadPosition: [0, 9], newHeadPosition: [0, 12]
          oldTailPosition: [0, 6], newTailPosition: [0, 6]
          hasTail: true, isValid: true, bufferChanged: false
        }]

        changes = []
        marker.setHeadPosition([0, 3])
        expect(marker.getRange()).toEqual [[0, 3], [0, 6]]
        expect(marker.isReversed()).toBe true
        expect(changes).toEqual [{
          oldHeadPosition: [0, 12], newHeadPosition: [0, 3]
          oldTailPosition: [0, 6], newTailPosition: [0, 6]
          hasTail: true, isValid: true, bufferChanged: false
        }]

        changes = []
        marker.setHeadPosition([0, 9])
        expect(marker.getRange()).toEqual [[0, 6], [0, 9]]
        expect(marker.isReversed()).toBe false
        expect(changes).toEqual [{
          oldHeadPosition: [0, 3], newHeadPosition: [0, 9]
          oldTailPosition: [0, 6], newTailPosition: [0, 6]
          hasTail: true, isValid: true, bufferChanged: false
        }]