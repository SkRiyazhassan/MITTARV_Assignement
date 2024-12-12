import React, { useState } from 'react';
import { DragDropContext, Droppable, Draggable } from 'react-beautiful-dnd';
import './App.css'; // Add custom CSS for styling

const App = () => {
  const [tasks, setTasks] = useState({
    todo: [],
    inProgress: [],
    peerReview: [],
    done: [],
  });

  const [searchQuery, setSearchQuery] = useState('');
  const [showAddTaskModal, setShowAddTaskModal] = useState(false);
  const [newTask, setNewTask] = useState({ title: '', description: '' });

  const onDragEnd = (result) => {
    const { source, destination } = result;

    // Return if dropped outside of a valid area
    if (!destination) return;

    const sourceColumn = source.droppableId;
    const destColumn = destination.droppableId;

    const sourceTasks = Array.from(tasks[sourceColumn]);
    const destTasks = Array.from(tasks[destColumn]);

    const [movedTask] = sourceTasks.splice(source.index, 1);

    if (sourceColumn === destColumn) {
      sourceTasks.splice(destination.index, 0, movedTask);
      setTasks((prevTasks) => ({
        ...prevTasks,
        [sourceColumn]: sourceTasks,
      }));
    } else {
      destTasks.splice(destination.index, 0, movedTask);
      setTasks((prevTasks) => ({
        ...prevTasks,
        [sourceColumn]: sourceTasks,
        [destColumn]: destTasks,
      }));
    }
  };

  const addTask = () => {
    if (newTask.title.trim() === '') return;

    const newTaskWithId = {
      ...newTask,
      id: `${Date.now()}`, // Generate a unique ID using timestamp
    };

    setTasks((prevTasks) => ({
      ...prevTasks,
      todo: [newTaskWithId, ...prevTasks.todo],
    }));

    setNewTask({ title: '', description: '' });
    setShowAddTaskModal(false);
  };

  const filteredTasks = (column) =>
    tasks[column].filter((task) =>
      task.title.toLowerCase().includes(searchQuery.toLowerCase())
    );

  return (
    <div className="kanban-board">
      <header>
        <input
          type="text"
          placeholder="Search tasks..."
          value={searchQuery}
          onChange={(e) => setSearchQuery(e.target.value)}
        />
      </header>
      <DragDropContext onDragEnd={onDragEnd}>
        <div className="columns">
          {Object.keys(tasks).map((column) => {
            return (
              <Droppable key={column} droppableId={column}>
                {(provided) => {
                  return (
                    <div
                      className="column"
                      ref={provided.innerRef}
                      {...provided.droppableProps}
                    >
                      <h2>{column}</h2>
                      {filteredTasks(column).map((task, index) => (
                        <Draggable key={task.id} draggableId={task.id} index={index}>
                          {(provided) => {
                            return (
                              <div
                                className="task-card"
                                ref={provided.innerRef}
                                {...provided.draggableProps}
                                {...provided.dragHandleProps}
                              >
                                <h3>{task.title}</h3>
                                <p>{task.description}</p>
                              </div>
                            );
                          }}
                        </Draggable>
                      ))}
                      {provided.placeholder} {/* This is necessary for the Droppable component */}
                    </div>
                  );
                }}
              </Droppable>
            );
          })}
        </div>
      </DragDropContext>
      <button className="add-task-btn" onClick={() => setShowAddTaskModal(true)}>
        + Add Task
      </button>
      {showAddTaskModal && (
        <div className="modal">
          <div className="modal-content">
            <h3>Add New Task</h3>
            <input
              type="text"
              placeholder="Task Title"
              value={newTask.title}
              onChange={(e) =>
                setNewTask({ ...newTask, title: e.target.value })
              }
            />
            <textarea
              placeholder="Task Description"
              value={newTask.description}
              onChange={(e) =>
                setNewTask({ ...newTask, description: e.target.value })
              }
            />
            <button onClick={addTask}>Add</button>
            <button onClick={() => setShowAddTaskModal(false)}>Cancel</button>
          </div>
        </div>
      )}
    </div>
  );
};

export default App;
