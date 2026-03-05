public class ConcreteShapeFactory{
       public static void testFactory() {
        Shape s1 = ShapeFactory.createShape('Circle');
        s1.draw();  // Output: Drawing a Circle

        Shape s2 = ShapeFactory.createShape('Square');
        s2.draw();  // Output: Drawing a Square

        Shape s3 = ShapeFactory.createShape('Triangle');
        s3.draw();  // Output: Drawing a Triangle
    }
}