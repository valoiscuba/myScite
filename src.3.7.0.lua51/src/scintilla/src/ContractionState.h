// Scintilla source code edit control
/** @file ContractionState.h
 ** Manages visibility of lines for folding and wrapping.
 **/
// Copyright 1998-2007 by Neil Hodgson <neilh@scintilla.org>
// The License.txt file describes the conditions under which this software may be distributed.

#ifndef CONTRACTIONSTATE_H
#define CONTRACTIONSTATE_H

namespace Scintilla {

template<class T>
class SparseVector;

/**
 */
class ContractionState {
	// These contain 1 element for every document line.
	std::unique_ptr<RunStyles<Sci::Line, char>> visible;
	std::unique_ptr<RunStyles<Sci::Line, char>> expanded;
	std::unique_ptr<RunStyles<Sci::Line, int>> heights;
	std::unique_ptr<SparseVector<UniqueString>> foldDisplayTexts;
	std::unique_ptr<Partitioning<Sci::Line>> displayLines;
	Sci::Line linesInDocument;

	void EnsureData();

	bool OneToOne() const {
		// True when each document line is exactly one display line so need for
		// complex data structures.
		return visible == nullptr;
	}

public:
	ContractionState();
	// Deleted so ContractionState objects can not be copied.
	ContractionState(const ContractionState &) = delete;
	void operator=(const ContractionState &) = delete;
	virtual ~ContractionState();

	void Clear();

	Sci::Line LinesInDoc() const;
	Sci::Line LinesDisplayed() const;
	Sci::Line DisplayFromDoc(Sci::Line lineDoc) const;
	Sci::Line DisplayLastFromDoc(Sci::Line lineDoc) const;
	Sci::Line DocFromDisplay(Sci::Line lineDisplay) const;

	void InsertLine(Sci::Line lineDoc);
	void InsertLines(Sci::Line lineDoc, Sci::Line lineCount);
	void DeleteLine(Sci::Line lineDoc);
	void DeleteLines(Sci::Line lineDoc, Sci::Line lineCount);

	bool GetVisible(Sci::Line lineDoc) const;
	bool SetVisible(Sci::Line lineDocStart, Sci::Line lineDocEnd, bool isVisible);
	bool HiddenLines() const;

	const char *GetFoldDisplayText(Sci::Line lineDoc) const;
	bool SetFoldDisplayText(Sci::Line lineDoc, const char *text);

	bool GetExpanded(Sci::Line lineDoc) const;
	bool SetExpanded(Sci::Line lineDoc, bool isExpanded);
	bool GetFoldDisplayTextShown(Sci::Line lineDoc) const;
	Sci::Line ContractedNext(Sci::Line lineDocStart) const;

	int GetHeight(Sci::Line lineDoc) const;
	bool SetHeight(Sci::Line lineDoc, int height);

	void ShowAll();
	void Check() const;
};

}

#endif
