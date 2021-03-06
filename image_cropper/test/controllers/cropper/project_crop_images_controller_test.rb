require 'test_helper'

class Cropper::ProjectCropImagesControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  setup :initialize_project, :initialize_project_image, :initialize_project_crop_image

  # called after every single test
  def teardown
    @project = nil
    @project_image = nil
  end

  test "should authenticate get index" do
    get :index, project_id: @project, project_image_id: @project_image
    assert_redirected_to new_user_session_path
  end

  test "should get index" do
    sign_in users(:cropper)
    get :index, project_id: @project, project_image_id: @project_image
    assert_response :success
  end

  test "should get index 2" do
    sign_in users(:cropper)
    get :index, project_id: @project, project_image_id: project_images(:two).id
    assert_response :success
  end

  test "should return invalid format" do
    sign_in users(:cropper)
    get :index, project_id: @project, project_image_id: @project_image, format: 'png'
    assert_response :unsupported_media_type
  end

  test "should authenticate create" do
    post :create, project_id: @project, project_image_id: @project_image, project_crop_image: {project_image_id: @project_image.id, image: "20150922205514.jpg"}, cords: {"0"=>{"x"=>"78.51666259765625", "y"=>"339"}, "1"=>{"x"=>"78.51666259765625", "y"=>"271"}, "2"=>{"x"=>"183.51666259765625", "y"=>"268"}, "3"=>{"x"=>"186.51666259765625", "y"=>"340"}}
    assert_redirected_to new_user_session_path
  end

  test "should create" do
    setup_project_crop_image_files
    sign_in users(:cropper)
    post :create, project_id: @project, project_image_id: @project_image,
                  project_crop_image: { project_image_id: @project_image.id, image: "20150922205514.jpg",
                                        tag_id: Tag.first.id },
                  cords: {"0"=>{"x"=>"78.51666259765625", "y"=>"339"}, "1"=>{"x"=>"78.51666259765625", "y"=>"271"}, "2"=>{"x"=>"183.51666259765625", "y"=>"268"}, "3"=>{"x"=>"186.51666259765625", "y"=>"340"}}, format: :json
    assert_response :created
  end

  test "should raise crop error on create" do
    setup_project_crop_image_files
    sign_in users(:cropper)
    class TestClass
      def call(foo)
        `false`
        false
      end
    end
    assert_raise "Could not crop image" do
      @controller.stub :system, TestClass.new do
        post :create, project_id: @project, project_image_id: @project_image,
                      project_crop_image: { project_image_id: @project_image.id, image: "20150922205514.jpg",
                                            tag_id: Tag.first.id },
                      cords: {"0"=>{"x"=>"78.51666259765625", "y"=>"339"}, "1"=>{"x"=>"78.51666259765625", "y"=>"271"}, "2"=>{"x"=>"183.51666259765625", "y"=>"268"}, "3"=>{"x"=>"186.51666259765625", "y"=>"340"}}, format: :json
      end
    end
  end

  test "should authenticate update" do
    pci = project_crop_images(:one)
    patch :update, project_id: pci.project, project_image_id: pci.project_image, format: :json, id: pci,
          project_crop_image:
              { id: pci.id, cords: {"0"=>{"x"=>"90", "y"=>"339"}, "1"=>{"x"=>"90", "y"=>"271"}, "2"=>{"x"=>"160", "y"=>"268"}, "3"=>{"x"=>"160", "y"=>"340"}}}
    assert_response :unauthorized
  end

  test "should authorize update" do
    sign_in users(:cropper)
    pci = project_crop_images(:four)
    patch :update, project_id: pci.project, project_image_id: pci.project_image, id: pci, format: :json,
          project_crop_image:
              { id: pci.id, cords: {"0"=>{"x"=>"90", "y"=>"339"}, "1"=>{"x"=>"90", "y"=>"271"}, "2"=>{"x"=>"160", "y"=>"268"}, "3"=>{"x"=>"160", "y"=>"340"}}}
    assert_response :unauthorized
  end

  test "should authorize update uploader" do
    sign_in users(:uploader2)
    pci = project_crop_images(:four)
    patch :update, project_id: pci.project, project_image_id: pci.project_image, id: pci, format: :json,
          project_crop_image:
              { id: pci.id, cords: {"0"=>{"x"=>"90", "y"=>"339"}, "1"=>{"x"=>"90", "y"=>"271"}, "2"=>{"x"=>"160", "y"=>"268"}, "3"=>{"x"=>"160", "y"=>"340"}}}
    assert_response :unauthorized
  end

  test "should update uploader" do
    sign_in users(:uploader)
    pci = project_crop_images(:four)
    patch :update, project_id: pci.project, project_image_id: pci.project_image, id: pci, format: :json,
          project_crop_image:
              { id: pci.id, cords: {"0"=>{"x"=>"90", "y"=>"339"}, "1"=>{"x"=>"90", "y"=>"271"}, "2"=>{"x"=>"160", "y"=>"268"}, "3"=>{"x"=>"160", "y"=>"340"}}}
    assert_response :ok
  end

  test "should update cropper" do
    sign_in users(:cropper1)
    pci = project_crop_images(:four)
    patch :update, project_id: pci.project, project_image_id: pci.project_image, id: pci, format: :json,
          project_crop_image:
              { id: pci.id, cords: {"0"=>{"x"=>"90", "y"=>"339"}, "1"=>{"x"=>"90", "y"=>"271"}, "2"=>{"x"=>"160", "y"=>"268"}, "3"=>{"x"=>"160", "y"=>"340"}}}
    assert_response :ok
  end

  test "should update admin" do
    sign_in users(:admin)
    pci = project_crop_images(:four)
    patch :update, project_id: pci.project, project_image_id: pci.project_image, id: pci, format: :json,
          project_crop_image:
              { id: pci.id, cords: {"0"=>{"x"=>"90", "y"=>"339"}, "1"=>{"x"=>"90", "y"=>"271"}, "2"=>{"x"=>"160", "y"=>"268"}, "3"=>{"x"=>"160", "y"=>"340"}}}
    assert_response :ok
  end

  test "should validate on update" do
    sign_in users(:admin)
    pci = project_crop_images(:four)
    patch :update, project_id: pci.project, project_image_id: pci.project_image, id: pci, format: :json,
          project_crop_image:
              { id: pci.id, cords: {"0"=>{"x"=>"90", "y"=>"339"}, "1"=>{"x"=>"90", "y"=>"271"}, "2"=>{"x"=>"160", "y"=>"268"}}}
    assert_response :unprocessable_entity
  end

  test "should validate on create" do
    sign_in users(:cropper)
    post :create, project_id: @project, project_image_id: @project_image,
                  project_crop_image: {image: "20150922205514.jpg"},
                  cords: {"0"=>{"x"=>"78.51666259765625", "y"=>"339"}, "1"=>{"x"=>"78.51666259765625", "y"=>"271"}, "2"=>{"x"=>"183.51666259765625", "y"=>"268"},
                          "3"=>{"x"=>"186.51666259765625", "y"=>"340"}}, format: :json
    assert_response :unprocessable_entity
  end

  test "should authenticate destroy" do
    delete :destroy, project_id: @project, project_image_id: @project_image, id: @project_crop_image.id
    assert_redirected_to new_user_session_path
  end

  test "should destroy" do
    setup_project_crop_image_files
    sign_in users(:cropper)
    delete :destroy, project_id: @project, project_image_id: @project_image, id: @project_crop_image.id, x: 10, y: 10, format: :json
    assert_response :accepted
  end

  private

  def initialize_project
    @project = projects(:one)
  end

  def initialize_project_image
    @project_image = project_images(:one)
  end

  def initialize_project_crop_image
    @project_crop_image = project_crop_images(:one)
  end
end
