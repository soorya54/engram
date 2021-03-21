import * as NotesApi from "../NotesApi";

describe("NotesApi", () => {
  describe("sortNotes", () => {
    it("should sort by createdAt", () => {
      const notes = [
        {
          localId: "1",
          createdAt: new Date(2021, 3, 20),
        },
        {
          localId: "2",
          createdAt: new Date(2021, 3, 19),
        },
      ];
      const sortedNotes = NotesApi.sortNotes(notes);
      expect(sortedNotes[0].localId).toBe("2");
      expect(sortedNotes[1].localId).toBe("1");
    });

    it("should sort by prev if exists", () => {
      const notes = [
        {
          localId: "1",
          prev: "2",
        },
        {
          localId: "2",
          createdAt: new Date(2021, 3, 20),
        },
        {
          localId: "3",
          createdAt: new Date(2021, 3, 19),
        },
      ];
      const sortedNotes = NotesApi.sortNotes(notes);
      expect(sortedNotes[0].localId).toBe("3");
      expect(sortedNotes[1].localId).toBe("2");
      expect(sortedNotes[2].localId).toBe("1");
    });
  });
});