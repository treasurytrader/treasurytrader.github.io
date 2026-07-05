//+------------------------------------------------------------------+
//|                                      Sort struct list By a field |
//|                                              Nomocp 2025, Nomocp |
//|                                              https://t.me/nomocp |
//+------------------------------------------------------------------+
struct ExStruct {
  double num;
  datetime time;

  ExStruct() {}
  ExStruct(double v_, datetime t_) : num(v_), time(t_) {}
  ExStruct(ExStruct &ps_) { Copy(ps_); }

  void Copy(ExStruct &ps_) {
    this.num  = ps_.num;
    this.time = ps_.time;
  }

  void operator=(ExStruct &ps_) {
    Copy(ps_);
  }
};

//+------------------------------------------------------------------+
//| QuickSort Ascending (Tăng dần)                                   |
//+------------------------------------------------------------------+
// O(n log n)
// QuickSort có thể chậm hơn nếu dữ liệu gần như đã sắp xếp.
void QuickSort(ExStruct &list[], int low, int high) { 
  if(low < high) {
    int pi = Partition(list, low, high);
    QuickSort(list, low, pi - 1);
    QuickSort(list, pi + 1, high);
  }
}

int Partition(ExStruct &list[], int low, int high) {
  datetime pivot = list[high].time;
  int i = low - 1;

  for(int j = low; j < high; ++j) {
    if(list[j].time > pivot) continue;
    ++i;
    ExStruct temp = list[i];
    list[i]       = list[j];
    list[j]       = temp;
  }

  ExStruct temp = list[i + 1];
  list[i + 1]   = list[high];
  list[high]    = temp;

  return i + 1;
}

//+------------------------------------------------------------------+
//| MergeSort Ascending (Tăng dần)                                   |
//+------------------------------------------------------------------+
// O(n log n)
void MergeSort(ExStruct &list[], int left, int right) { 
  if(left < right) {
    int mid = (left + right) / 2;
    MergeSort(list, left, mid);
    MergeSort(list, mid + 1, right);
    Merge(list, left, mid, right);
  }
}

void Merge(ExStruct &list[], int left, int mid, int right) {
  int n1 = mid - left + 1;
  int n2 = right - mid;

  ExStruct L[], R[];
  ArrayResize(L, n1);
  ArrayResize(R, n2);

  for(int i = 0; i < n1; ++i) L[i] = list[left + i];
  for(int j = 0; j < n2; ++j) R[j] = list[mid + 1 + j];

  int i = 0, j = 0, k = left;
  while(i < n1 && j < n2) {
    if (L[i].time <= R[j].time) list[k++] = L[i++];
    else list[k++] = R[j++];
  }

  while(i < n1) list[k++] = L[i++];
  while(j < n2) list[k++] = R[j++];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ExStruct psList[];

void OnStart() {
  AllocateArray(psList);
  Print("---- Quick Sort ----");
  QuickSort(psList, 0, ArraySize(psList) - 1);
  for(int i = 0; i < ArraySize(psList); ++i) {
    Print(i, " -> Value: ", psList[i].num, ", Time: ", TimeToString(psList[i].time));
  }

  AllocateArray(psList);
  Print("---- Merge Sort ----");
  MergeSort(psList, 0, ArraySize(psList) - 1);
  for(int i = 0; i < ArraySize(psList); ++i) {
    Print(i, " -> Value: ", psList[i].num, ", Time: ", TimeToString(psList[i].time));
  }
}

void AllocateArray(ExStruct &psList_[]) {
  ArrayResize(psList, 5);
  psList_[0] = ExStruct(1.0, D'2025.08.06 10:00');
  psList_[1] = ExStruct(2.0, D'2025.08.04 09:00');
  psList_[2] = ExStruct(3.0, D'2025.08.05 12:00');
  psList_[3] = ExStruct(4.0, D'2025.08.07 14:00');
  psList_[4] = ExStruct(5.0, D'2025.08.03 02:00');
}
//+------------------------------------------------------------------+
