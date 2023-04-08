
export const newEmployeeImpl = (a, b, c) =>
	new Employee(a, b, c);

export const employerImpl = obj => obj.employer;

export const roomImpl = obj => obj.room;

export const sayEmployerImpl = (obj) => obj.sayEmployer();

export const setRoomImpl = (a, obj) => obj.setRoom(a);