interface Student { 
    studentId: number; 
    name: string; 
}; 
const students: Student[] = [
    {
        studentId: 1000, 
        name: "Name 1"
    },
    {
        studentId: 1001, 
        name: "Name 2"
    },
    {
        studentId: 1002, 
        name: "Name 3"
    }
]; 
const getStudent = (id: Number) => { 
    // return students.find(students => students.studentId === id);
    return students.find(students => students.studentId === id)!;
}; 

const student: Student = getStudent(10001);