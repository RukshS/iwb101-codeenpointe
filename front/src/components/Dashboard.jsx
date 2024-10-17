import React from 'react';
import { useNavigate } from 'react-router-dom';

const Dashboard = () => {
  const navigate = useNavigate();

  const handleLogout = () => {
    localStorage.removeItem('token');
    navigate('/login');
  };

  return (
    <div className="dashboard-container">
      <h1>Welcome to the TikEvent Dashboard!</h1>
      <p>This is your dashboard where you can view and manage your event-related information.</p>
      <button onClick={handleLogout}>Logout
