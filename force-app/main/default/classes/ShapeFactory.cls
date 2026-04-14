public Class ShapeFactory {
     public static Shape createShape(String shapeType) {
        if (shapeType == null) {
            return null;
        }

        if (shapeType.equalsIgnoreCase('Circle')) {
            return new Circle();
        } else if (shapeType.equalsIgnoreCase('Square')) {
            return new Square();
        } else if (shapeType.equalsIgnoreCase('Triangle')) {
            return new Rectangle();
        } else {
            return null;
        }
    }
}