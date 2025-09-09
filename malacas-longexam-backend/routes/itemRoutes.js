const express = require('express');
const router = express.Router();
const itemController = require('../controllers/itemController'); // <-- make sure path is correct

// Routes
router.get('/', itemController.getItems);
router.get('/:id', itemController.getItemByName);
router.post('/', itemController.createItem);
router.put('/:id', itemController.updateItem);
router.delete('/:id', itemController.deleteItem);

module.exports = router;
