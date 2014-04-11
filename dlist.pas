{ DList.pas -- doubly-linked list, with current pointer }

unit DList;

interface

type
  ListEntry = integer;
  ListPointer = ^ListNode;
  ListNode = record
    entry: ListEntry;
    next: ListPointer;     { pointer to the next node in the list }
    prev: ListPointer; { pointer to the previous node in the list }
  end;
  Position = integer;

  List = record
    head: ListPointer;    { points to the first node of the list }
    count: integer;       { number of entries in the list }
  end;

procedure CreateList (var L:List);
procedure InsertList (pos: Position; x: ListEntry; var L: List);
procedure DeleteList (pos: Position; var x: ListEntry; var L: List);
procedure RetrieveList (pos: Position; var x: ListEntry; var L: List);
procedure ReplaceList (pos: Position; x: ListEntry; var L: List);
procedure ClearList (var L: List);
function ListEmpty (var L: List): boolean;
function ListFull (var L: List): boolean;
function ListSize (var L: List): integer;
procedure PrintList (var L: List);

implementation

procedure Error (emesg: String);
begin
  writeln(emesg);
end;


procedure SetPosition (pos: Position; var L: List; var p: ListPointer);
{ Pre:  pos is a valid position on list L: 1<=pos<=L.count.
  Post: The list pointer p points to the list node at position pos. }
var i: Position;
begin
  if (pos<1) or (pos>L.count) then
    Error('Attempt to set to a position not on the list.')
  else begin
    p := L.head;
    for i := 2 to pos do p := p^.next;
  end;
end;


procedure CreateList (var L:List);
{ Pre:  None.
  Post: L is created as empty list }
begin
  L.head := nil;
  L.count := 0;
end;

procedure PrintList (var L:List);
{ Pre:  The list L has been created. }
{ Post: The entries in L are printed in sequence. }
var p: ListPointer;
begin
  write('[ ');
  p := L.head;
  while p<>nil do begin
    write(p^.entry, ' ');
    p := p^.next;
  end;
  writeln(']');
end;

procedure InsertList (pos: Position; x: ListEntry; var L: List);
{ Pre:  The List L has been created, L is not full,
        x is a valid list entry, and 1<=pos<=L.count+1.
  Post: x has been inserted into position pos in L; the entry formerly
        in position pos (provided pos<=n) and all later entries have
        their position numbers increased by 1. }
var newnode: ListPointer;  { pointer to the new node }
    p, q: ListPointer;     { temp storage for inserting }
begin
  if (pos<=0) or (pos>L.count+1) then
    Error('Attempt to insert in a position not on the list.')
  else begin
    new(newnode);
    newnode^.entry := x;
    if L.count=0 then begin
      { case 1: insert a node into an empty list.  pos must be 1. }
      newnode^.next := nil;
      newnode^.prev := nil;
      L.head := newnode;
    end else if pos=1 then begin
      { case 2: insert a node as 1st node (pos=1) in a nonempty list. }
      newnode^.prev := nil;
      newnode^.next := L.head;
      L.head^.prev := newnode;
      L.head := newnode;
    end else if pos=L.count+1 then begin
      { case 3: insert a node as last node in a nonempty list. }
      SetPosition(L.count, L, p);
      p^.next := newnode;
      newnode^.prev := p;
      newnode^.next := nil;
    end else begin
      { case 4: insert a node in between two existing nodes:  }
      {         p, at position pos-1, and q, at position pos. }
      SetPosition(pos-1, L, p);
      q := p^.next;
      p^.next := newnode;
      newnode^.prev := p;
      newnode^.next := q;
      q^.prev := newnode;
    end;
    L.count := L.count + 1;
  end;
end;

procedure DeleteList (pos: Position; var x: ListEntry; var L: List);
{ Pre:  The list L has been created, L is not empty, and 1<=pos<=L.count.
  Post: The entry in position pos of L has been returned as x and deleted
        from L; the entries in all later position (provided pos<n) have
        their position numbers decreased by 1. }
var delnode: ListPointer;
    p, q: ListPointer;     { temp storage for deleting }

begin
  if ListEmpty(L) then
    Error('Attempt to delete from an empty L.')
  else if (pos<=0) or (pos>L.count) then
    Error('Attempt to delete in a position not on the list.')
  else begin
    if L.count=1 then begin
      { case 1: delete the only node from a list of size 1 }
      delnode := L.head;
      L.head := nil;
    end else if pos=1 then begin
      { case 2: delete the first node of a list of size > 1 }
      delnode := L.head;
      L.head := delnode^.next;
      L.head^.prev := nil;
    end else if pos=L.count then begin
      { case 3: delete the last node of a list of size > 1 }
      SetPosition(L.count-1, L, p);
      delnode := p^.next;
      p^.next := nil;
    end else begin
      { case 4: delete a node in between two existing nodes }
      { We need to delete the node at position pos. }
      { Point p to the node before it (i.e.(pos-1)th node) and  }
      {       q to the node after it  (i.e.(pos+1)th node)      }
      SetPosition(pos-1, L, p);
      delnode := p^.next;
      q := delnode^.next;
      p^.next := q;
      q^.prev := p;

      { You can also do this more concisely .. }
      { SetPosition(pos, L, delnode); }
      { delnode^.prev^.next := delnode^.next; }
      { delnode^.next^.prev := delnode^.prev; }
    end;
    L.count := L.count - 1;
    x := delnode^.entry;
    dispose(delnode);
  end;
end;


procedure RetrieveList (pos: Position; var x: ListEntry; var L: List);
{ Pre:  The list L has been created, L is not empty, and 1<=pos<=L.count.
  Post: The entry in position pos of L has been returned as x.
        L remains unchanged. }
var p: ListPointer;
begin
  if ListEmpty(L) then
    Error('Attempt to retrieve from an empty L.')
  else if (pos<=0) or (pos>L.count) then
    Error('Attempt to retrieve a position not on the list.')
  else begin
    SetPosition(pos,L,p);
    x := p^.entry;
  end;
end;


procedure ReplaceList (pos: Position; x: ListEntry; var L: List);
{ Pre:  The list L has been created, L is not empty,
        x is a valid list entry, and 1<=pos<=L.count.
  Post: The entry in position pos of L has been relaced by x.
        The other entries of L remain unchanged. }
var p: ListPointer;
begin
  if ListEmpty(L) then
    Error('Attempt to replace an entry in an empty L.')
  else if (pos<=0) or (pos>L.count) then
    Error('Attempt to replace a position not on the list.')
  else begin
    SetPosition(pos,L,p);
    p^.entry := x;
  end;
end;

procedure ClearList (var L: List);
{ Pre:  The list L has been created.
  Post: The list L becomes empty. }
var p,delnode: ListPointer;
begin
  p := L.head;
  while p<>nil do begin
    delnode := p;
    p := p^.next;
    dispose(delnode);
  end;
  L.head := nil;
  L.count := 0;
end;

function ListEmpty (var L: List): boolean;
{ Pre:  The list L has been created }
{ Post: returns true if L is empty, false otherwise. }
begin
  ListEmpty := (L.count=0);
end;

function ListFull (var L: List): boolean;
{ Pre:  The list L has been created. }
{ Post: returns true if L is full, false otherwise. }
begin
  ListFull := false;
end;

function ListSize (var L: List): integer;
{ Pre:  The list L has been created. }
{ Post: returns the number of entries in L. }
begin
  ListSize := L.count;
end;

begin
end.
